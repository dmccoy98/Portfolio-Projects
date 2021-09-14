

-- Cleaning Data in SQL Queries

select *
from [Portfolio Project]..NashvilleHousing






-- Standardizing the Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from [Portfolio Project]..NashvilleHousing


update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)







-- Populate Property Address


select *
from [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null







-- Breaking up Address into Individual Columns (Address, City, State)


select PropertyAddress
from [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from [Portfolio Project]..NashvilleHousing



alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))






select OwnerAddress
from [Portfolio Project]..NashvilleHousing



select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from [Portfolio Project]..NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)




alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)








-- Chang Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [Portfolio Project]..NashvilleHousing



update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end










-- Remove Duplicates


with RowNumCTE as(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from [Portfolio Project]..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress






-- Delete Unused Columns


select *
from [Portfolio Project]..NashvilleHousing


alter table [Portfolio Project]..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table [Portfolio Project]..NashvilleHousing
drop column SaleDate






