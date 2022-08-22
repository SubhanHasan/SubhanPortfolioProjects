/*

Cleaning Nashville Housing Data using SQL queries.

*/


SELECT *
FROM DataCleanProject..NashvilleData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM DataCleanProject..NashvilleData


ALTER TABLE NashvilleData
ADD SaleDateConverted Date;

UPDATE NashvilleData
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM DataCleanProject..NashvilleData
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataCleanProject..NashvilleData a
JOIN DataCleanProject..NashvilleData b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is null




UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataCleanProject..NashvilleData a
JOIN DataCleanProject..NashvilleData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null







--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


ALTER TABLE NashvilleData
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleData
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
FROM DataCleanProject..NashvilleData




SELECT PropertyAddress
FROM DataCleanProject..NashvilleData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM DataCleanProject..NashvilleData





SELECT OwnerAddress
FROM DataCleanProject..NashvilleData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM DataCleanProject..NashvilleData




ALTER TABLE NashvilleData
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleData
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE NashvilleData
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


SELECT * 
FROM DataCleanProject..NashvilleData



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM DataCleanProject..NashvilleData
GROUP by SoldAsVacant
ORDER by 2




SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleanProject..NashvilleData


UPDATE NashvilleData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM DataCleanProject..NashvilleData


--Ordering by ParcelID
)
SELECT *

--DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER by PropertyAddress



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM DataCleanProject..NashvilleData


ALTER TABLE DataCleanProject..NashvilleData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

















