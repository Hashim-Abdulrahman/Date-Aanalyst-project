/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate from NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;


UPDATE NashvilleHousing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d, %Y');



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;

 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;
 
 
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing;


SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 2), ',', -1)) AS City,
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS State
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 2), ',', -1));


ALTER TABLE NashvilleHousing
ADD PropertySplitState VARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitState = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));


SELECT *
FROM NashvilleHousing;


SELECT OwnerAddress
FROM NashvilleHousing;


SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerCity,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerState
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));


ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);


UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));


SELECT *
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
       END AS SoldAsVacantNew
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                   END;

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM NashvilleHousing
    ) AS sub
    WHERE sub.row_num > 1
);


SELECT *
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
