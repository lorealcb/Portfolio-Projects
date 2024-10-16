/*

 Cleaning Data in SQL Queries

 */
 SELECT *
 FROM NashvilleHousing

 --Standardize Date Format
 SELECT SaleDateConverted, CONVERT(Date, SaleDate)
 FROM NashvilleHousing

 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(Date, SaleDate)


 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted Date;

 UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(Date, SaleDate)


 -------------------------------------------------------------------------------------
 -- Populate Property Address data

 SELECT *
 FROM NashvilleHousing
 --WHERE PropertyAddress is NULL
 ORDER By ParcelID 
 
 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL




	-------------------------------------------------------------------------------------------------------------
	---Breaking out Address into Individual data
SELECT PropertyAddress
 FROM NashvilleHousing
 --WHERE PropertyAddress is NULL
 --ORDER By ParcelID 

 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
 FROM NashvilleHousing



  ALTER TABLE NashvilleHousing
 ADD PropertySplitAddress NVARCHAR(255);

 UPDATE NashvilleHousing
 SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
 ADD PropertySplitCity NVARCHAR(255);

 UPDATE NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

 Select*
 FROM NashvilleHousing


 ------------------------------------------------------------------
 --Seperate out the OwnerAddress into Address, City, State (easier than above)
 SELECT OwnerAddress
 FROM NashvilleHousing

 SELECT
 PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
 ,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
 ,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
 FROM NashvilleHousing




 ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddress NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3) 

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitState NVARCHAR(255);

 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1) 

  SELECT *
  FROM NashvilleHousing


  -----------------------------------------------------------------------------------------------
  ---Change Y and N to Yes and No in "Sold as Vacant" field
  SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
  FROM NashvilleHousing
  Group by SoldAsVacant
  Order by 2

  SELECT SoldAsVacant
  , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
  FROM NashvilleHousing


  UPDATE NashvilleHousing
  SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
  FROM NashvilleHousing

  -----------------------------------------------------------------
  ---Remove Duplicates

----CTE start area-----
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
FROM NashvilleHousing 
)
--- This will remove duplicates

  DELETE
  FROM RowNumCTE
  WHERE row_num > 1
  ---ORDER BY PropertyAddress
  -----------------THe CTE must all excute together to work---------------
  
  SELECT *
  FROM RowNumCTE
  WHERE row_num > 1
 --- ORDER BY PropertyAddress

 -----Reiteration of CTE to ensure it works----------
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
FROM NashvilleHousing 
)
SELECT *
  FROM RowNumCTE
  WHERE row_num > 1
    ------Shows there are no more duplicate values------
 ----------------------------------------------
 ----------------Delete unused columns--------------------------------------
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, 
			TaxDistrict,
			PropertyAddress
	
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
	