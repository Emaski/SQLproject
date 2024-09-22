
select * 
from PortfolioProject..NashvilleHousing

--Standerdizing the date format

ALTER TABLE NashvilleHousing
Add saleDateConverted Date

UPDATE NashvilleHousing
SET saleDateConverted = CONVERT(Date, saleDate)

select *
from PortfolioProject..NashvilleHousing

--

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out PropertyAddress into individual columns

select PropertyAddress
from PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
 FROM PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 ALTER TABLE NashvilleHousing
Add PropertySplitCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select * 
FROM PortfolioProject..NashvilleHousing

--Breaking down OwnerAddress into individual columns

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

 ALTER TABLE NashvilleHousing
Add OwnerSplitCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

 ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

select DISTINCT SoldAsVacant, count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

select SoldAsVacant,
 CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
 END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


--Remove Duplicates
WITH rowNumCTE AS (
select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID ,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing)

SELECT *
FROM rowNumCTE
where row_num > 1
Order By PropertyAddress 

-- Deleting unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

select *
from PortfolioProject..NashvilleHousing