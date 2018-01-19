Include %DeepSee

/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Utility methods for the DeepSee "HoleFoods" demo.
/// To create data for this DeepSee model, the easiest thing to do is to
/// use the <method>BuildData</method>:<br/>
/// From the command line:<br/>
/// <example language="cache">
/// Do ##class(HoleFoods.Utils).BuildData(1000000,1,1)
/// </example>
/// The first argument is the number of records to create, 
/// the second argument indicates that index building should be done in parallel,
/// the third is a verbose flag; if true, then progress is displayed as the data is built.
Class HoleFoods.Utils Extends %RegisteredObject
{

/// Add this alias so that each DeepSee sample has a Setup() method
ClassMethod Setup(pCount As %Integer = 1000, pASync As %Boolean = 1, pVerbose As %Boolean = 1)
{
	do ..BuildData(pCount,pASync,pVerbose)
}

/// Build the transactional data that will provide data for the DeepSee model.
/// Any old records will be deleted.<br/>
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pAsync</var> if true, indicates that parallel processing should be used to build the cube.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod BuildData(pCount As %Integer = 1000, pASync As %Boolean = 1, pVerbose As %Boolean = 1)
{
	// Delete cube if present
	If ##class(%DeepSee.Utils).%CubeExists("HOLEFOODS") {
		Do ##class(%DeepSee.Utils).%KillCube("HOLEFOODS")
	}

	// Kill old data
	Do ##class(Region).%KillExtent()
	Do ##class(Country).%KillExtent()
	Do ##class(Outlet).%KillExtent()
	Do ##class(Product).%KillExtent()
	Do ##class(Transaction).%KillExtent()

	// build new data
	Do ..CreateRecords(1,pCount,pVerbose)

	// update cube(s)
	If ##class(%DeepSee.Utils).%CubeExists("HOLEFOODS") {
		Set tSC = ##class(%DeepSee.Utils).%BuildCube("HOLEFOODS",pASync,pVerbose)
		If $$$ISERR(tSC) {
			Write !,"Error in BuildCube:"
			Do $System.Status.DisplayError(tSC)
		}
	}

	If ##class(%DeepSee.Utils).%CubeExists("HOLEFOODSBUDGET") {
		Set tSC = ##class(%DeepSee.Utils).%BuildCube("HOLEFOODSBUDGET",pASync,pVerbose)
		If $$$ISERR(tSC) {
			Write !,"Error in BuildCube:"
			Do $System.Status.DisplayError(tSC)
		}
	}

    //define term lists
    do ..SetupTermLists()

    //define pivot variables
    do ..SetupVariables()
}

/// Add new records to the transactional data that will provide data for the DeepSee model.
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pAsync</var> if true, indicates that parallel processing should be used to build the cube.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod AddData(pCount As %Integer = 100, pASync As %Boolean = 1, pVerbose As %Boolean = 1)
{
	// build new data
	Do ..CreateRecords(0,pCount,pVerbose)
}

/// Update existing records to the transactional data that will provide data for the DeepSee model.
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod UpdateData(pCount As %Integer = 100, pVerbose As %Boolean = 1)
{
	Set tChangeCount = 0
	Set tRecordCount = 100000
	For n=1:1:pCount {
		Set tID = $R(tRecordCount) + 1
		Set tRecord = ##class(HoleFoods.Transaction).%OpenId(tID)
		If $IsObject(tRecord) {
			Set tRecord.UnitsSold = $S($R(10)<8:1,1:$R(8)+1)
			Set tRecord.Discount = $S($R(10)<6:0,$R(10)<7:0.1,$R(10)<7:0.2,1:0.5)
			Set tRecord.AmountOfSale = tRecord.UnitsSold * tRecord.Product.Price * (1 - tRecord.Discount)
			Set tSC = tRecord.%Save()
			If $$$ISOK(tSC) {
				Set tChangeCount = tChangeCount + 1
				If (pVerbose) Write $C(13,27)_"[0J"_$FN(+$G(tChangeCount),",",0)_" record(s) updated"
			}
		}
	}
	If (pVerbose) Write $C(13,27)_"[0J"_$FN(+$G(tChangeCount),",",0)_" record(s) updated"
}

/// Delete a record in the transactional data that provides data for the DeepSee model.
/// <var>pStart</var> is the starting Id of the source record to delete.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod DeleteRecords(pStartId As %Integer, pEndId As %Integer = "", pVerbose As %Boolean = 1)
{
	Set:pEndId="" pEndId=pStartId
	For id=pStartId:1:pEndId {
		Set tSC = ##class(HoleFoods.Transaction).%DeleteId(id)
		If $$$ISERR(tSC) {
			Do:pVerbose $System.Status.DisplayError(tSC)
		}
	}

	If ##class(%DeepSee.Utils).%CubeExists("HOLEFOODS") {
		Do ##class(%DeepSee.Utils).%SynchronizeCube("HOLEFOODS",pVerbose)
	}
}

/// Does the actual work of creating new records in the source data.
/// <var>pCount</var> is the number of records to create.<br/>
/// <var>pAsync</var> if true, indicates that parallel processing should be used to build the cube.<br/>
/// <var>pVerbose</var> if true, indicates that status messages should be written to the console.<br/>
ClassMethod CreateRecords(pNewBuild As %Boolean, pCount As %Integer = 100, pVerbose As %Boolean = 1) [ Private ]
{
	Set tSC = $$$OK
	Try {
		// build new data

		// regions
		Set tTotalPopulation = 0

		If (pNewBuild) {
			// $LB(population,lat,long)
			Set tRegionList("Asia","Japan","Tokyo") = $LB(12369000,35.623,139.703)
			Set tRegionList("Asia","Japan","Osaka") = $LB(8817166,34.652,135.485)
			Set tRegionList("Asia","China","Beijing") = $LB(17400000,39.860,116.412)
			Set tRegionList("Asia","China","Shanghai") = $LB(16738000,31.224,121.466)
			Set tRegionList("Asia","India","Mumbai") = 	$LB(12778721,18.96,72.819)
			Set tRegionList("Asia","India","Bangalore") = 	$LB(6200000,12.963,77.587)

			Set tRegionList("Europe","England","London") = 	$LB(7287555,51.503,-0.145)
			Set tRegionList("Europe","England","Manchester") = $LB(2240230,53.470,-2.237)
			Set tRegionList("Europe","France","Paris") = 	$LB(11174000,48.844,2.355)
			Set tRegionList("Europe","France","Nice") = 	$LB(347100,43.709,7.266)
			Set tRegionList("Europe","Spain","Madrid") = 	$LB(7061748,40.415,-3.709)
			Set tRegionList("Europe","Spain","Barcelona") = $LB(1673075,41.387,2.169)
			Set tRegionList("Europe","Germany","Berlin") = 	$LB(5000000,52.527,13.402)
			Set tRegionList("Europe","Germany","Munich") = $LB(5203738,48.142,11.578)
			Set tRegionList("Europe","Germany","Frankfurt") = $LB(5600000,50.097,8.678)
			Set tRegionList("Europe","Belgium","Antwerp") = $LB(461496,51.212,4.393)
			Set tRegionList("Europe","Belgium","Brussels") = $LB(1830000,50.845,4.338)
			Set tRegionList("Europe","Netherlands","Amsterdam") = $LB(2158372,52.360,4.877)
			Set tRegionList("Europe","Italy","Rome") = 	$LB(2743796,41.879,12.473)
			Set tRegionList("Europe","Italy","Milan") = $LB(1310320,45.438,9.178)

			Set tRegionList("N. America","USA","Boston") = $LB(3406829,42.3612,-71.5)
			Set tRegionList("N. America","USA","New York") = $LB(19306183,40.785,-73.9639)
			Set tRegionList("N. America","USA","Los Angeles") = $LB(9948081,34.027,-118.264)
			Set tRegionList("N. America","USA","Seattle") = $LB(3263497,47.585,-122.350)
			Set tRegionList("N. America","USA","Atlanta") = $LB(5278904,33.757,-84.354)
			Set tRegionList("N. America","USA","Houston") = $LB(5628101,29.766,-95.390)
			Set tRegionList("N. America","USA","Chicago") = $LB(9785747,41.867,-87.639)
			Set tRegionList("N. America","USA","Sheridan") = $LB(15804,44.787,-106.959)

			Set tRegionList("N. America","Canada","Toronto") = $LB(5555912,43.638,-79.406)
			Set tRegionList("N. America","Canada","Montreal") = $LB(3635571,45.501,-73.562)
			Set tRegionList("N. America","Canada","Vancouver") = $LB(2524113,49.248,-123.109)

			Set tRegionList("S. America","Brasil","Sao Paolo") = $LB(11150249,-23.544,-46.635)
			Set tRegionList("S. America","Brasil","Rio De Janeiro") = $LB(7145472,-22.894,-43.228)
			Set tRegionList("S. America","Brasil","Brasilia") = $LB(2455903,-15.779,-47.932)
			Set tRegionList("S. America","Chile","Santiago") = $LB(7200000,-31.428,-70.562)

			// create index for finding geocode for customers
			Do ..CreateGeoIndex(.tRegionList)

			// regions
			Set r = $O(tRegionList(""))
			While (r '= "") {
				Set tRegion = ##class(Region).%New()
				Set tRegion.Name = r
				Set tSC = tRegion.%Save()
				If $$$ISERR(tSC) Quit

				// countries
				Set c = $O(tRegionList(r,""))
				While (c '= "") {
					Set tCountry = ##class(Country).%New()
					Set tCountry.Name = c
					Set tCountry.Region = tRegion
					Set tSC = tCountry.%Save()
					If $$$ISERR(tSC) Quit
					Set tCountryId = tCountry.%Id()

					// cities
					Set ct = $O(tRegionList(r,c,""))
					While (ct '= "") {
						Set tOutlet = ##class(Outlet).%New()
						Set tOutlet.City = ct
						Set tOutlet.Country = tCountry
						Set tPopulation = $LG(tRegionList(r,c,ct),1)
						Set tOutlet.Population = tPopulation
						Set tOutlet.Latitude = $LG(tRegionList(r,c,ct),2)
						Set tOutlet.Longitude = $LG(tRegionList(r,c,ct),3)
						Set tSC = tOutlet.%Save()
						If $$$ISERR(tSC) Quit
						Set tCityId = tOutlet.%Id()
						Set tCityCountry(tCityId) = tCountryId	// index used later

						// track total population and distribution
						// create records proportional to population
						Set tTotalPopulation = tTotalPopulation + tPopulation
						Set tCityDistribution(tTotalPopulation) = tOutlet.%Id()

						Set x = $I(tOutletCount)
						Set ct = $O(tRegionList(r,c,ct))
					}
					If $$$ISERR(tSC) Quit
					Set c = $O(tRegionList(r,c))
				}
				If $$$ISERR(tSC) Quit
				Set r = $O(tRegionList(r))
			}

			// Products: $LB(name,sku,price,type)
			Kill tList
			Set tList($I(tList)) = $LB("Bagels (dozen)","SKU-101",2.95,"Snack")
			Set tList($I(tList)) = $LB("Donuts (dozen)","SKU-192",2.95,"Snack")
			Set tList($I(tList)) = $LB("Pretzels (bag)","SKU-203",3.95,"Snack")
			Set tList($I(tList)) = $LB("Unsalted Pretzels (bag)","SKU-204",4.25,"Snack")
			Set tList($I(tList)) = $LB("Free-range Donuts (dozen)","SKU-195",12.95,"Snack")
			Set tList($I(tList)) = $LB("Bundt Cake","SKU-199",19.95,"Snack")
			Set tList($I(tList)) = $LB("Ziti (box)","SKU-296",1.95,"Pasta")
			Set tList($I(tList)) = $LB("Penne (box)","SKU-287",1.95,"Pasta")
			Set tList($I(tList)) = $LB("Tortellini (frozen)","SKU-928",6.95,"Pasta")
			Set tList($I(tList)) = $LB("Cheerios (box)","SKU-709",3.95,"Cereal")
			Set tList($I(tList)) = $LB("Fruit Loops (box)","SKU-708",4.95,"Fruit")
			Set tList($I(tList)) = $LB("Pineapple Rings (can)","SKU-900",8.95,"Fruit")
			Set tList($I(tList)) = $LB("Lifesavers (roll)","SKU-451",1.15,"Candy")
			Set tList($I(tList)) = $LB("Swiss Cheese (sliced)","SKU-712",5.95,"Dairy")
			Set tList($I(tList)) = $LB("Onion ring","SKU-222",5.95,"Vegetable")
			Set tList($I(tList)) = $LB("Onion ring","SKU-223",4.95,"Vegetable")
			Set tList($I(tList)) = $LB("Calamari (frozen)","SKU-601",22.95,"Seafood")

			Set tProductCount = 0
			Set n = $O(tList(""))
			While (n '= "") {
				Set tProduct = ##class(Product).%New()
				Set tProduct.Name = $LG(tList(n),1)
				Set tProduct.SKU = $LG(tList(n),2)
				Set tProduct.Price = $LG(tList(n),3)
				Set tProduct.Category = $LG(tList(n),4)
                Set tSC = tProduct.%Save()
                If $$$ISERR(tSC) Quit
                If tProduct.SKU = "SKU-296" {
                        Set tDefaultProduct = tProduct
                }

				// build random distribution of products
				Set c = $R(10)+1
				For k = 1:1:c {
					Set tProducts($I(tProductCount)) = tProduct
				}
				Set n = $O(tList(n))
			}
			If $$$ISERR(tSC) Quit

			// certain products are not sold in certain regions
			Set tSkipProduct("Asia","SKU-101") = ""
			Set tSkipProduct("Asia","SKU-712") = ""
			Set tSkipProduct("Europe","SKU-195") = ""
			Set tSkipProduct("N. America","SKU-204") = ""
		}
		Else {
			// use existing star tables

			// cities
			Set tRS = ##class(%ResultSet).%New()
			Set tSC = tRS.Prepare("SELECT ID FROM HoleFoods.Outlet")
			If $$$ISERR(tSC) Quit
			Set tSC = tRS.Execute()
			If $$$ISERR(tSC) Quit

			While (tRS.Next()) {
				Set tID = tRS.Data("ID")
				Set tCity = ##class(Outlet).%OpenId(tID)
				If $IsObject(tCity) {
					Set tCities($I(tCityCount)) = tCity
				}
			}

			// products
			Set tRS = ##class(%ResultSet).%New()
			Set tSC = tRS.Prepare("SELECT ID FROM HoleFoods.Product")
			If $$$ISERR(tSC) Quit
			Set tSC = tRS.Execute()
			If $$$ISERR(tSC) Quit

			While (tRS.Next()) {
				Set tID = tRS.Data("ID")
				Set tProduct = ##class(Product).%OpenId(tID)
				If $IsObject(tProduct) {
					// build random distribution of products
					Set c = $R(10)+1
					For k = 1:1:c {
						Set tProducts($I(tProductCount)) = tProduct
					}
				}
			}
		}

		// distribution of dates increasing with time
		// last 5 full years, plus part of current year
		Set tCurrYear = +$E($ZDT($H,3),1,4)
		Set tStartYear = tCurrYear - 5
		Set tCurrMonth = +$E($ZDT($H,3),6,7)
		Set tMonthSeed = 1000
		Set tMonthTotal = tMonthSeed
		Set tMonths = 60 + tCurrMonth
		For m = 1:1:tMonths {
			Set tMonthTotal = (tMonthTotal * 1.01)\1
			Set tMonthDist(tMonthTotal) = m
		}

		// now build main table
		Set tCount = pCount
		Set tRows = 0

		For n = 1:1:tCount {
			Set tRecord = ##class(Transaction).%New()
			Set tRecord.Actual = 1
		
			// last 5 full years plus part of current year, with distribution increasing with time
			Set tMonth = 1
			Set mr = $R(tMonthTotal - tMonthSeed) + tMonthSeed
			Set mi = $O(tMonthDist(mr))
			Set:mi'="" tMonth = $G(tMonthDist(mi),1)

			Set tYear = tStartYear + ((tMonth-1)\12)
			Set tMonth = ((tMonth-1)#12) + 1
			Set tDay = $R($$$iscDaysInMonth(tYear,tMonth)) + 1
			Set tH = +$ZDTH(tYear_"-"_$$$iscPadZero(tMonth,2)_"-"_$$$iscPadZero(tDay,2),3)

			Set tRecord.DateOfSale = tH
			
			// product
			Set tProduct = tProducts($R(tProductCount)+1)
			Set tRecord.Product = tProduct

			Set tRecord.UnitsSold = $S($R(10)<8:1,1:$R(8)+1)
			Set tRecord.Discount = $S($R(10)<6:0,$R(10)<7:0.1,$R(10)<7:0.2,1:0.5)
			Set tRecord.AmountOfSale = tRecord.UnitsSold * tProduct.Price * (1 - tRecord.Discount)

			// slowly change channel distribution
			Set tRecord.Channel = $S($R(18000)<(tH-50000):2,1:1)

			// some are null
			If ($R(10) < 1) Set tRecord.Channel = ""

			// assign outlet weighted by population
			If (pNewBuild) {
				If ($R(100)<2) {
					Set tRecord.Comment = ..CreateComment()
				}

				Set tOutletId = 1
				Set lr = $R(tTotalPopulation)
				Set li = $O(tCityDistribution(lr))
				Set:li'="" tOutletId = $G(tCityDistribution(li),1)

				Set tCity = ##class(Outlet).%OpenId(tOutletId)
				Set tRecord.Outlet = tCity

				// keep running total (of rounded values) for budget
				If (tYear '= tCurrYear) {
					Set tDate = tYear_"-"_$$$iscPadZero(tMonth,2)
					Set tProductId = tProduct.%Id()
					// round up and add random variation
					Set tValue = ((tRecord.AmountOfSale+0.5)*100)\100
					If (tProductId["2") {
						Set tValue = tValue * 1.2
					}
					ElseIf (tProductId["9") {
						Set tValue = tValue * 0.8
					}
					If (tOutletId=3) {
						Set tValue = tValue * 1.2
					}
					ElseIf (tOutletId=8) {
						Set tValue = tValue * 0.8
					}
					Set tSalesTotal(tDate,tProductId,tOutletId) = $G(tSalesTotal(tDate,tProductId,tOutletId)) + tValue
				}
			}
			Else {
				Set tCity = tCities($R(tCityCount)+1)
				Set tRecord.Outlet = tCity
			}

			// for U.S. cities we can add more customer info
			If ($IsObject(tRecord.Outlet) && (tRecord.Outlet.Country.Name = "USA")) {
				If (..GetCustomerLocation(tRecord.Outlet.City,.tZipCode,.tLat,.tLng)) {
					Set tRecord.ZipCode = tZipCode
					Set tRecord.Latitude = tLat
					Set tRecord.Longitude = tLng
				}
			}

			// test for skipped products
			If ($IsObject(tRecord.Outlet) && $IsObject(tRecord.Product)) {
				Set tRegionName = tRecord.Outlet.Country.Region.Name
				Set tSKU = tRecord.Product.SKU
				If ((tRegionName'="")&&(tSKU'="")){
					If $D(tSkipProduct(tRegionName,tSKU)) {
                          Set tRecord.Product = tDefaultProduct
 					}
				}
			}

   			Set tSC = tRecord.%Save()
			If $$$ISERR(tSC) {
				Do $System.Status.DisplayError(tSC)
			}
			Else {
				Set tRows = tRows + 1
			}
			If (pVerbose&&('(tRows#1000))) Write $C(13,27)_"[0J"_$FN(tRows,",",0)_" rows created"
		}

		If (pNewBuild) {
			// create budget records for current year
			Set tGrowth = 1.1
			
			// take last full year actuals and multiply by growth
			For m =1:1:12 {
				Set tDate = (tCurrYear-1)_"-"_$$$iscPadZero(m,2)
				Set tCurrDate = (tCurrYear)_"-"_$$$iscPadZero(m,2)
				
				Set tProductId = $O(tSalesTotal(tDate,""))
				While (tProductId'="") {
					Set tOutletId = $O(tSalesTotal(tDate,tProductId,""))
					While (tOutletId'="") {
						Set tOldValue = tSalesTotal(tDate,tProductId,tOutletId)
						Set tSalesTotal(tCurrDate,tProductId,tOutletId) = tOldValue * tGrowth
						Set tOutletId = $O(tSalesTotal(tDate,tProductId,tOutletId))
					}
					Set tProductId = $O(tSalesTotal(tDate,tProductId))
				}
			}

			// insert budget records
			Set tDate = $O(tSalesTotal(""))
			While (tDate'="") {
				Set tProductId = $O(tSalesTotal(tDate,""))
				While (tProductId'="") {
					Set tOutletId = $O(tSalesTotal(tDate,tProductId,""))
					While (tOutletId'="") {

						Set tRecord = ##class(Transaction).%New()
						Set tRecord.Actual = 0
						Set tRecord.TargetAmount = tSalesTotal(tDate,tProductId,tOutletId)
						Do tRecord.ProductSetObjectId(tProductId)
						Do tRecord.OutletSetObjectId(tOutletId)
						Set tRecord.DateOfSale = +$ZDTH(tDate_"-01",3)
						Set tSkip = 0

						// test for skipped products
						If ($IsObject(tRecord.Outlet) && $IsObject(tRecord.Product)) {
							Set tRegionName = tRecord.Outlet.Country.Region.Name
							Set tSKU = tRecord.Product.SKU
							If ((tRegionName'="")&&(tSKU'="")){
								If $D(tSkipProduct(tRegionName,tSKU)) {
									Set tSkip = 1
								}
							}
						}
						If ('tSkip) {
							Set tSC = tRecord.%Save()
						}
						If $$$ISERR(tSC) {
							Do $System.Status.DisplayError(tSC)
						}
						Else {
							Set tRows = tRows + 1
						}
						If (pVerbose&&('(tRows#1000))) Write $C(13,27)_"[0J"_$FN(tRows,",",0)_" rows created"
						Set tOutletId = $O(tSalesTotal(tDate,tProductId,tOutletId))
					}
					Set tProductId = $O(tSalesTotal(tDate,tProductId))
				}
				Set tDate = $O(tSalesTotal(tDate))
			}
		}

		If (pVerbose) Write $C(13,27)_"[0J"_$FN(+$G(tRows),",",0)_" row(s) created"

		// Kill geodata index
		Kill ^||HoleFoods.GeoData
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}

	If $$$ISERR(tSC) {
		Do $System.Status.DisplayError(tSC)
	}
}

/// Create a temp index of geo locations in the US.
ClassMethod CreateGeoIndex(ByRef pRegionList) As %Status
{
	Set tSC = $$$OK
	Try {
		Kill ^||HoleFoods.GeoData

		// loop over cities in USA
		// build index of zipcode near each city
		// not very efficient, but this is a demo!
		// Set tRegionList("N. America","USA","Boston") = $LB(3406829,42.3612,-78.0824)
		Set tStoreCity = $O(pRegionList("N. America","USA",""),1,tStoreData)
		While (tStoreCity'="") {
			Set tStoreLat = $LG(tStoreData,2)
			Set tStoreLng = $LG(tStoreData,3)

			// visit each zip code
			Set z = $O(^ZipCodeData(""),1,tData)
			While (z'="") {
				Set tLat = $LG(tData,4)
				Set tLng = $LG(tData,3)
				If ((tLat'="")&&(tLng'="")) {
					Set d = ((tStoreLat-tLat)*(tStoreLat-tLat)) + ((tStoreLng-tLng)*(tStoreLng-tLng))
					If (d < 10) {
						Set nx = $I(^||HoleFoods.GeoData(tStoreCity))
						Set ^||HoleFoods.GeoData(tStoreCity,nx) = $LB(z,tLat,tLng)
					}
				}
				Set z = $O(^ZipCodeData(z),1,tData)
			}

			Set tStoreCity = $O(pRegionList("N. America","USA",tStoreCity),1,tStoreData)
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// Get city, latitude, and longitude for customer near the given store.
ClassMethod GetCustomerLocation(pStoreCity As %String, Output pZipCode As %String, Output pLatitude As %Double, Output pLongitude As %Double) As %Boolean
{
	If $D(^||HoleFoods.GeoData) {
		// find city near the store
		Set nc = +$G(^||HoleFoods.GeoData(pStoreCity))

		If (nc>0) {
			Set n = $R(nc) + 1
			Set tZipData = $G(^||HoleFoods.GeoData(pStoreCity,n))
			If (tZipData'="") {
				Set pZipCode = $LG(tZipData,1)
				Set pLatitude = $LG(tZipData,2)
				Set pLongitude = $LG(tZipData,3)
				Quit 1
			}
		}
	}
	Quit 0
}

/// Return a random comment for a transaction.
ClassMethod CreateComment() As %String
{
	Set tComment = ""

	Set tSubject($I(tSubject)) = "Customer"
	Set tSubject($I(tSubject)) = "Shopper"

	Set tVerb($I(tVerb)) = " complained about"
	Set tVerb($I(tVerb)) = " complained about"
	Set tVerb($I(tVerb)) = " complained about"
	Set tVerb($I(tVerb)) = " ranted about"
	Set tVerb($I(tVerb)) = " was happy about"
	Set tVerb($I(tVerb)) = " commented on"

	Set tObject($I(tObject)) = " prices"
	Set tObject($I(tObject)) = " high prices"
	Set tObject($I(tObject)) = " outrageous prices"
	Set tObject($I(tObject)) = " ridiculous prices"
	Set tObject($I(tObject)) = " freshness"
	Set tObject($I(tObject)) = " quality"
	Set tObject($I(tObject)) = " service"
	Set tObject($I(tObject)) = " coupons"
	Set tObject($I(tObject)) = " advertising"
	Set tObject($I(tObject)) = " cashier"
	Set tObject($I(tObject)) = " appearance of store"
	Set tObject($I(tObject)) = " availability of items"

	Set tComment = tSubject($R(tSubject)+1) _ tVerb($R(tVerb)+1) _ tObject($R(tObject)+1)
	Quit tComment
}

/// Change the (display) name of the specified product.
ClassMethod ChangeProductName(pProductID As %String, pNewName As %String)
{
	Set tProduct = ##class(Product).%OpenId(pProductID)
	If $IsObject(tProduct) {
		Set tProduct.Name = pNewName
		Set tSC = tProduct.%Save()
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
	}
	Else {
		Write "Product not found: ",pProductID,!
	}
}

/// Add a new product and update the cube.
ClassMethod AddProduct(pRecordID As %String, pSKU As %String, pNewName As %String)
{
	Set tRecord = ##class(Transaction).%OpenId(pRecordID)
	If $IsObject(tRecord) {
		Set tProduct = ##class(Product).%New()
		Set tProduct.SKU = pSKU
		Set tProduct.Name = pNewName
		Set tProduct.Price = 2.95
		Set tSC = tProduct.%Save()
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
		Set tRecord.Product = tProduct
		Set tSC = tRecord.%Save()
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
		// Update cube
		Set tSC = ##class(Cube).%UpdateFacts(pRecordID)
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
	}
	Else {
		Write "Record not found: ",pRecordID,!
	}
}

/// Add a new product and update the cube.
ClassMethod ChangeMeasure(pRecordID As %String, pUnitsSold As %Integer)
{
	Set tRecord = ##class(Transaction).%OpenId(pRecordID)
	If $IsObject(tRecord) {
		Set tRecord.UnitsSold = pUnitsSold
		Set tRecord.AmountOfSale = pUnitsSold * tRecord.Product.Price
		Write "Product: ",tRecord.Product.Name,!
		Set tSC = tRecord.%Save()
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
		// Update cube
		Set tSC = ##class(Cube).%UpdateFacts(pRecordID)
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
	}
	Else {
		Write "Record not found: ",pRecordID,!
	}
}

/// Add a new product and update the cube.
ClassMethod ChangeCity(pRecordID As %String, pNewCityID As %Integer)
{
	Set tRecord = ##class(Transaction).%OpenId(pRecordID)
	If $IsObject(tRecord) {
		If ($IsObject(tRecord.Outlet)) {
			Set tCity = tRecord.Outlet.City
		}
		Set tRecord.Outlet = ##class(Outlet).%OpenId(pNewCityID)
		Set tSC = tRecord.%Save()
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
		// Update cube
		Set tSC = ##class(Cube).%UpdateFacts(pRecordID)
		If $$$ISERR(tSC) {
			Do $System.Status.DisplayError(tSC)
			Quit
		}
	}
	Else {
		Write "Record not found: ",pRecordID,!
	}
}

/// Purely for demo purposes, this method defines term lists used by this sample.
ClassMethod SetupTermLists()
{
	set name="Region Colors"
	set uname="REGION COLORS"
	write "Defining term list ",name,"...",!
	
	//cannot assume the following will work from release to release; replace with use of API when available
	kill ^DeepSee.TermList(uname)
	set ^DeepSee.TermList(uname,"name")=name
	set ^DeepSee.TermList(uname,"modDate")=$zdt($h,3)
	set ^DeepSee.TermList(uname,"data","Asia","VALUE")="Aqua"
	set ^DeepSee.TermList(uname,"data","Europe","VALUE")="BlueViolet"
	set ^DeepSee.TermList(uname,"data","N. America","VALUE")="Firebrick"
	set ^DeepSee.TermList(uname,"data","S. America","VALUE")="Green"
}

/// Purely for demo purposes, this method defines pivot variables used by this sample.
ClassMethod SetupVariables()
{
	//cannot assume the following will work from release to release; replace with use of API when available

	write "Defining COMMISSIONPERCENTAGE pivot variable for HOLEFOODS cube",!
	kill ^DeepSee.Variables("HOLEFOODS","COMMISSIONPERCENTAGE")
	set ^DeepSee.Variables("HOLEFOODS","COMMISSIONPERCENTAGE")=$lb("CommissionPercentage","Commission Percentage","","0","literal","integer","manual","","0,5,10,11,12,13,14,15","")

	write "Defining YEAR pivot variable for HOLEFOODS cube",!
	kill ^DeepSee.Variables("HOLEFOODS","YEAR")
	set ^DeepSee.Variables("HOLEFOODS","YEAR")=$lb("Year","Year","","NOW","literal","string","kpi","HoleFoodsYears.kpi","","")
}

}

