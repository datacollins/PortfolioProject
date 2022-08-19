/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject..NashvilleHousing

-- standardize sale date

select SaleDateConverted, cast(saledate as date)
from NashvilleHousing

update NashvilleHousing
set SaleDate = cast(SaleDate as date)

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = cast(SaleDate as date)

-- populate property address data

select *
from NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns(address, city, state)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, len(PropertyAddress))

select *
from NashvilleHousing

-- now instead of substring you can use parsename. LET'S GO!!!

select OwnerAddress
from NashvilleHousing

select
parsename(REPLACE(OwnerAddress, ',' , '.'), 3),
parsename(REPLACE(OwnerAddress, ',' , '.'), 2),
parsename(REPLACE(OwnerAddress, ',' , '.'), 1)
from NashvilleHousing
order by 2

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',' , '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',' , '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(REPLACE(OwnerAddress, ',' , '.'), 1)

select *
from NashvilleHousing

-- change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end

-- Delete duplicates

with RowNumCTE as ( 
select *,
	ROW_NUMBER()over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
from NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from NashvilleHousing

-- now we delete the multiple rows

with RowNumCTE as ( 
select *,
	ROW_NUMBER()over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
from NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--deleting unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table NashvilleHousing
drop column saledate