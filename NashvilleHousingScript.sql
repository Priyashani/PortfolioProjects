/*

Data Cleaning in SQL

*/

Select * from Portfolio..NashvilleHousing

-- Standardize date format and remove the time component

select SaleDate, CONVERT(Date,SaleDate)
from Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Since the update command doesn't work, create a new column and put the value there
ALTER TABLE Portfolio..NashvilleHousing
Add SaleDateConverted Date;

Update Portfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDate, SaleDateConverted
from Portfolio..NashvilleHousing

-- Populate Porperty Address for where it is missing

select *
From Portfolio..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- If two records have same parcelID they should have the same Property address, use this is populate null PropertyAddress
-- UniqueID is unique to each row but parcelID is duplicated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- After making sure the select is correct do the update to PropertyAddress
Update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking up the address to Address line and City
-- Using Substring method
Select PropertyAddress
FROM Portfolio..NashvilleHousing

Select 
	SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-- Break the owner address to address line, city and state
-- Using Parsename

Select OwnerAddress
from Portfolio..NashvilleHousing

--Parsename only check for periods (.) so replace the comma
Select 
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From Portfolio..NashvilleHousing

-- Create three new columns and use parsename to set values to them by breaking the owneraddress
ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update Portfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update Portfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update Portfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- SoldAsVacant column need updating since it has two values representing yes and two for no
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolio..NashvilleHousing
Group by SoldAsVacant
order by 2

-- 'Y' is converted to 'Yes' and 'N' to 'No'
Select SoldAsVacant
, Case WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
from Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing
SET SoldAsVacant = Case 
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates
-- Useing windows function row_number

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY UniqueID
				 ) row_num
From Portfolio..NashvilleHousing
)
Delete 
From RowNumCTE
Where row_num >1

-- Delete Unused Columns

Select * 
From Portfolio..NashvilleHousing


Alter Table Portfolio..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table Portfolio..NashvilleHousing
Drop Column SaleDate