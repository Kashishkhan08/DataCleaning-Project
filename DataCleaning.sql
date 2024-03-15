 select *
 from nashvilleDataCleaning

 --standard date format
 select convertedDate, CONVERT(date, SaleDate)
  from nashvilleDataCleaning

 alter table nashvilleDataCleaning
add convertedDate date;

update nashvilleDataCleaning
set convertedDate=CONVERT(date, SaleDate)


--populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from [Portfolio-Project]..nashvilleDataCleaning a
 join [Portfolio-Project]..nashvilleDataCleaning b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from  [Portfolio-Project]..nashvilleDataCleaning a
 join [Portfolio-Project]..nashvilleDataCleaning b
  on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null

 
 --breaking address into address, city, state

select  NewAddress,city
 from [Portfolio-Project]..nashvilleDataCleaning

 alter table [Portfolio-Project]..nashvilleDataCleaning
 add NewAddress nvarchar(255);

update [Portfolio-Project]..nashvilleDataCleaning
set NewAddress=SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

 alter table [Portfolio-Project]..nashvilleDataCleaning
 add city nvarchar(255);

update [Portfolio-Project]..nashvilleDataCleaning
set city=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from [Portfolio-Project]..nashvilleDataCleaning


select OwnerSplitAddress,
OwnerCity,
OwnerState
from [Portfolio-Project]..nashvilleDataCleaning

alter table [Portfolio-Project]..nashvilleDataCleaning
add OwnerSplitAddress nvarchar(255);

update [Portfolio-Project]..nashvilleDataCleaning
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [Portfolio-Project]..nashvilleDataCleaning
add OwnerCity nvarchar(255);

update [Portfolio-Project]..nashvilleDataCleaning
set OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table [Portfolio-Project]..nashvilleDataCleaning
add OwnerState nvarchar(255);

update [Portfolio-Project]..nashvilleDataCleaning
set OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1)


--change y and n to yes and no in sold as vacant field

select distinct(SoldAsVacant)
from [Portfolio-Project]..nashvilleDataCleaning

select SoldAsVacant
--case when SoldAsVacant='y' then 'yes'
--     when SoldAsVacant='n' then 'no'
--	 else SoldAsVacant
--	 end
from [Portfolio-Project]..nashvilleDataCleaning

update [Portfolio-Project]..nashvilleDataCleaning
set SoldAsVacant=case when SoldAsVacant='y' then 'yes'
     when SoldAsVacant='n' then 'no'
	 else SoldAsVacant
	 end


--remove duplicates

with rownumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID
			 )row_num

from [Portfolio-Project]..nashvilleDataCleaning
)
select * from rownumCTE
where row_num>1


--delete unused columns

select *
from [Portfolio-Project]..nashvilleDataCleaning


alter table [Portfolio-Project]..nashvilleDataCleaning
drop column  convertedDate,OwnerAddress,TaxDistrict, PropertyAddress

alter table [Portfolio-Project]..nashvilleDataCleaning
drop column SaleDate