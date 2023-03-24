/*

Cleaning Data in SQL

*/


select *
from NasvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- Changing Date Format


 -- 1

select SaleDate, CONVERT(Date, SaleDate)
from NasvilleHousing

update NasvilleHousing
set SaleDate = CONVERT(Date, SaleDate)


-- 2

alter table NasvilleHousing
add SalesDate date 

update NasvilleHousing
set SalesDate = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Data

select *
from NasvilleHousing
order by ParcelID


select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress,ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
from NasvilleHousing NH1
join NasvilleHousing NH2
  on NH1.ParcelID = NH2.ParcelID
  and NH1.[UniqueID ] <> NH2.[UniqueID ]
where NH1.PropertyAddress is null


update NH1
set PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
from NasvilleHousing NH1
join NasvilleHousing NH2
  on NH1.ParcelID = NH2.ParcelID
  and NH1.[UniqueID ] <> NH2.[UniqueID ]
where NH1.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Column (Address, City, State)


-- Breaking out Property Address

select PropertyAddress
from NasvilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
from NasvilleHousing


alter table NasvilleHousing
add PropertySplitAddress nvarchar(255)

alter table NasvilleHousing
add PropertyCity nvarchar(255)


update NasvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update NasvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



-- Breaking out Owner Address

select OwnerAddress
from NasvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from NasvilleHousing


alter table NasvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table NasvilleHousing
add OwnerCity nvarchar(255)

alter table NasvilleHousing
add OwnerState nvarchar(255)


update NasvilleHousing
set ownersplitaddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

update NasvilleHousing
set ownercity = PARSENAME(replace(owneraddress, ',', '.'), 2)

update NasvilleHousing
set ownerstate = PARSENAME(replace(owneraddress, ',', '.'), 1)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Changing Y and N in "Sold as Vacant" field


select distinct(SoldAsVacant), count(soldasvacant)
from NasvilleHousing
group by SoldAsVacant


select SoldAsVacant
,case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from NasvilleHousing


update NasvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Removing Duplicates 

 with RownumCTE as(
select *,
  ROW_NUMBER()over( 
  partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
		       SaleDate,
			   LegalReference
	 ORDER BY
			   UniqueID) row_num
from NasvilleHousing
)
select *
from RownumCTE
where row_num > 1


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Deleting Unused Columns 

select *
from NasvilleHousing

alter table NasvilleHousing
drop column propertyaddress, saledate, taxdistrict, owneraddress

