-- Standarize date format

select *
from SQLdatabase.dbo.Sheet1$

select saledateconv, CONVERT(date,saledate)
from SQLdatabase.dbo.Sheet1$

update SQLdatabase.dbo.Sheet1$
set SaleDate = CONVERT(date,saledate)

alter table SQLdatabase.dbo.Sheet1$
add saledateconv date;

update SQLdatabase.dbo.Sheet1$
set saledateconv = CONVERT(date,saledate)

-- Populate property address data

select *
from SQLdatabase.dbo.Sheet1$
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from SQLdatabase.dbo.Sheet1$ a
join SQLdatabase.dbo.Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from SQLdatabase.dbo.Sheet1$ a
join SQLdatabase.dbo.Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual colums (Address, City, State)

select PropertyAddress
from SQLdatabase.dbo.Sheet1$

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from SQLdatabase.dbo.Sheet1$

alter table SQLdatabase.dbo.Sheet1$
add PropertySplit varchar(255);

update SQLdatabase.dbo.Sheet1$
set PropertySplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table SQLdatabase.dbo.Sheet1$
add PropertySplitcity varchar(255);

update SQLdatabase.dbo.Sheet1$
set PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from SQLdatabase.dbo.Sheet1$

select OwnerAddress
from SQLdatabase.dbo.Sheet1$

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from SQLdatabase.dbo.Sheet1$

alter table SQLdatabase.dbo.Sheet1$
add Ownersplitadd varchar(255);

update SQLdatabase.dbo.Sheet1$
set Ownersplitadd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table SQLdatabase.dbo.Sheet1$
add Ownersplitcity varchar(255);

update SQLdatabase.dbo.Sheet1$
set Ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table SQLdatabase.dbo.Sheet1$
add Ownersplitstate varchar(255);

update SQLdatabase.dbo.Sheet1$
set Ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from SQLdatabase.dbo.Sheet1$

-- Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from SQLdatabase.dbo.Sheet1$
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from SQLdatabase.dbo.Sheet1$

update SQLdatabase.dbo.Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--Remove Duplicates
with rownumCTE as(
select *,
row_number() over (
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
				UniqueID
				) row_num

from SQLdatabase.dbo.Sheet1$
--order by ParcelID
)
--delete
select *
from rownumCTE
where row_num > 1
order by PropertyAddress

-- Delete Unused Columns

select *
from SQLdatabase.dbo.Sheet1$

alter table SQLdatabase.dbo.Sheet1$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate