--*** CLEANING DATA FROM NASHVILLE HOUSING ***

--  STANDARDIZING DATES

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate);

--populating property address data
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null;
order by ParcelID;

select a.ParcelID, b.ParcelID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


-- MAKING ADDRESS INDIVIDUAL ADDRESS COLUMNS

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress,  1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousing
SET PropertySplitAddress  = substring(PropertyAddress,  1, CHARINDEX(',', PropertyAddress)-1) 



ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);


Update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

select *
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME (REPLACE(OwnerAddress,',', '.'),3),
PARSENAME (REPLACE(OwnerAddress,',', '.'),2),
PARSENAME (REPLACE(OwnerAddress,',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);


Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME (REPLACE(OwnerAddress,',', '.'),3) 



ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',', '.'),2);


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',', '.'),1)


-- Changing Y and N to yes and no

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



-- REMOVING DUPLICATES


WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				    ) row_num


From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
WHERE row_num > 1

--DELETING UNUSED COLUMNS

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


