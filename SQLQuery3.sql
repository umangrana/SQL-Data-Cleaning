/*
Cleaning Data in SQL Queries
*/

USE Db

Select *
From db.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From db.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET saleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From db.dbo.NashvilleHousing
WHERE propertyaddress is null

Select a.ParcelID , a.PropertyAddress,b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From db.dbo.NashvilleHousing a JOIN db.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.uniqueID <> b.uniqueID
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From db.dbo.NashvilleHousing a JOIN db.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.uniqueID <> b.uniqueID
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select propertyaddress 
From db.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From db.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



Select * From db.dbo.NashvilleHousing


--- Another Method to delimit/separate text from a cell instead of using SUBSTRINGS:

Select OwnerAddress From db.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From db.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState  Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



Select * From db.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant) , count(SoldAsVacant)
From db.dbo.NashvilleHousing
GROUP BY soldasvacant


SELECT SoldAsVacant,

CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END AS New
From db.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						Else SoldAsVacant
					END



Select Distinct(SoldAsVacant) , count(SoldAsVacant)
From db.dbo.NashvilleHousing
GROUP BY soldasvacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
	
	WITH RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER(PARTITION BY PropertyAddress,
									 SalePrice,
									 SaleDate,
									 LegalReference
									 ORDER BY
										UniqueID
										) AS row_num

	From db.dbo.NashvilleHousing
	--ORDER BY parcelID
	)SELECT * FROM RowNumCTE 
	WHERE row_num > 1
	ORDER BY PropertyAddress

	--Here we created a CTE that in which we used PARITION BY to Partition the data and assign a unique row_number, basically it will asssign count of similar records
	-- we used CTE and filtered for rownumber > 1 (which means duplicates or records which are similar and are appearing for more than 1 time)

-- Deleting rows
WITH RowNumCTEDelete AS(
	Select *,
	ROW_NUMBER() OVER(PARTITION BY PropertyAddress,
									 SalePrice,
									 SaleDate,
									 LegalReference
									 ORDER BY
										UniqueID
										) AS row_num

	From db.dbo.NashvilleHousing
	--ORDER BY parcelID
	)Delete FROM RowNumCTEDelete 
	WHERE row_num > 1
	





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * From db.dbo.NashvilleHousing


ALTER TABLE db.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict 

ALTER TABLE db.dbo.NashvilleHousing
DROP COLUMN SaleDate





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO










