-- Let's select our data first

Select *
From [Nashville Data Cleaning].dbo.NashvilleHousing

-- Date format
-- This data is currently in a datetime format. We will change it to be separate date and time columns. 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From [Nashville Data Cleaning].dbo.NashvilleHousing

-- Now the SaleDateConverted column is in a date format, without the time. 

-- Next, we will populate any null values in the property address column. We do this by using the fact that
-- there are multiple entries with the same parcelID. If there are same values and one's PropertyAddress is missing,
-- we can copy the other's propertyaddress into the missing field. i.e. rows 159 and 160 below.

Select *
From [Nashville Data Cleaning].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Data Cleaning].dbo.NashvilleHousing a
JOIN [Nashville Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

-- Now updating the table a to actually reflect our changes and setting the old column to the new. 
-- After running the bottom query, the top query should have 0 rows when run again. 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Data Cleaning].dbo.NashvilleHousing a
JOIN [Nashville Data Cleaning].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Now let's break out the address into individual columns for street address, city, and state

Select *
From [Nashville Data Cleaning].dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From [Nashville Data Cleaning].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add StreetAddress Nvarchar(255);

Update NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add City Nvarchar(255);

Update NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From [Nashville Data Cleaning].dbo.NashvilleHousing

-- Now we will do the same task for the OwnerName column, but with a different procedure. 
-- Here we use ParseName. This function only works with periods, so replace commas with periods. 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Nashville Data Cleaning].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerStreetAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From [Nashville Data Cleaning].dbo.NashvilleHousing


-- Now let's standarize the SoldAsVacant column. The first query shows our different values in there. 

Select distinct(SoldAsVacant)
From [Nashville Data Cleaning].dbo.NashvilleHousing

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
 	   When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From [Nashville Data Cleaning].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
 	   When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Data Cleaning].dbo.NashvilleHousing
Group by SoldAsVacant


