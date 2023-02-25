--- Cleaning Date Project (Nashville Housing Dataset)

SELECT * 
FROM NashvilleHousing 

------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT (Date, SaleDate)
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT (Date, SaleDate)

------------------------------------------------------------

-- Populate Property Address data 

SELECT *  
FROM NashvilleHousing 
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(A.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

------------------------------------------------------------

-- Breaking out Address into Indivdual Columns (Address, City State)

SELECT PropertyAddress
FROM NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As City
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT owneraddress
FROM Nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From Nashvillehousing 


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing 
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END 
FROM NashVilleHousing 

UPDATE NashVilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END 

 ------------------------------------------------------------

-- Remove Duplicate 

With RowNumCTE AS (
Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID) row_num
From NashVilleHousing 
)
Select *
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress


 ------------------------------------------------------------

-- Delete Unused Columns 

Select *
From NashVilleHousing 

ALTER TABLE NashVilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashVilleHousing 
DROP COLUMN SaleDate



