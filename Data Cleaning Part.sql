/*Cleaning data in sql*/
select * from PortfolioProject.dbo.NasvilleHousing

--standardize data format
select SaleDateConvert,convert(date,SaleDate) from PortfolioProject.dbo.NasvilleHousingagain

update NasvilleHousing
set SaleDate=convert(Date,SaleDate)

alter table NasvilleHousing
add SaleDateConvert Date

update NasvilleHousing
set SaleDateConvert=Convert(Date,SaleDate)

--populated property address date
select * from PortfolioProject.dbo.NasvilleHousing 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress) 
from PortfolioProject.dbo.NasvilleHousing as a  join PortfolioProject.dbo.NasvilleHousing as b
on a.ParcelID=b.ParcelID and a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is null

-- it's update the self join and put the b.propertyaddress into null value of a.propertyadress respectivelly 
update a 
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NasvilleHousing a
join PortfolioProject.dbo.NasvilleHousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null

--Breaking the address in individual columns
select PropertyAddress from PortfolioProject.dbo.NasvilleHousing

select SUBSTRING(PropertyAddress,1,charindex(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as city
from PortfolioProject.dbo.NasvilleHousing

alter table NasvilleHousing
add PropertySplitAddress nvarchar(255)

update NasvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,charindex(',',propertyaddress)-1)

alter table NasvilleHousing
add PropertySplitcity nvarchar(255)

update NasvilleHousing
set PropertySplitcity=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

--seprate owner address into subparts
select * from PortfolioProject.dbo.NasvilleHousing
select PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NasvilleHousing

alter table NasvilleHousing
add OwnerSplitAddress nvarchar(255)

update NasvilleHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NasvilleHousing
add OwnerSplitCity nvarchar(255)

update NasvilleHousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NasvilleHousing
add OwnerSplitState nvarchar(255)

update NasvilleHousing
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)


--change Y and N to Yes and No in "sold as vacant" feild
select distinct SoldAsVacant,count(soldasvacant)
from PortfolioProject.dbo.NasvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject.dbo.NasvilleHousing


update NasvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

--remove duplicates fom table
with RowNumCTE as(
select * , ROW_NUMBER() OVER(
		Partition By ParcelId, 
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference 
		order by UniqueID) row_num
from PortfolioProject.dbo.NasvilleHousing
--order by ParcelID
)
Select * from RowNumCTE where row_num=1 Order By Propertyaddress

--delete unused columns
select * from PortfolioProject.dbo.NasvilleHousingAgain