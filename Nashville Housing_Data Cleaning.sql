--Cleaning data in SQL

select *
from PortfolioProject..NashvilleHousing


------------------------------------------------
--Standardize Date Format

select Saledateconverted, CONVERT(date, saledate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date, saledate)

Alter table Nashvillehousing
add Saledateconverted Date;

Update NashvilleHousing
Set Saledateconverted = CONVERT(date, saledate)


--------------------------------------------
--Populate Property Adress data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
  on a.parcelid = b.parcelid
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
  on a.parcelid = b.parcelid
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null


  --------------------------------------------------------------------
  --Breaking out Address into Individual Columns (Adress, City, State)


select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Adress
from PortfolioProject..NashvilleHousing

Alter table Nashvillehousing
add PropertySplitAdress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAdress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table Nashvillehousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


Select 
Owneraddress,
PARSENAME(Replace(Owneraddress, ',', '.'),3),
PARSENAME(Replace(Owneraddress, ',', '.'),2),
PARSENAME(Replace(Owneraddress, ',', '.'),1)
from PortfolioProject..NashvilleHousing

Alter table Nashvillehousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(Owneraddress, ',', '.'),3)

Alter table Nashvillehousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(Owneraddress, ',', '.'),2)

Alter table Nashvillehousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(Owneraddress, ',', '.'),1)


select *
from PortfolioProject..NashvilleHousing


-------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct SoldAsVacant, count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 desc

Select Soldasvacant,
   case 
       when Soldasvacant = 'Y' then 'Yes'
       when Soldasvacant = 'N' then 'No'
	   Else Soldasvacant
	   End
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
 Set Soldasvacant = case 
       when Soldasvacant = 'Y' then 'Yes'
       when Soldasvacant = 'N' then 'No'
	   Else Soldasvacant
	   End
from PortfolioProject..NashvilleHousing



----------------------------------------------------------
--Remove Duplicates

With RowNumCTE as(
select *,
        Row_number() over(
		partition by parcelID,
					 Propertyaddress,
					 Saledate,
					 LegalReference
					 order by 
						UniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
from RownumCTE
where row_num >1
--order by PArcelID


-----------------------------------------------------
--Delete Unsued Columns


select *
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Drop Column Saledate, Owneraddress, Taxdistrict, Propertyaddress
