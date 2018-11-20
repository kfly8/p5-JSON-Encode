use Benchmark qw(cmpthese);

use JSON::TypeEncoder;
use Types::Standard -types;
use JSON::XS ();
use JSON::PP ();
use JSON::Types;

# http://dist.schmorp.de/misc/json/long.json
my $data = JSON::XS::decode_json(
'{"ResultSet":{"totalResultsAvailable":95,"totalResultsReturned":20,"firstResultPosition":1,"ResultSetMapUrl":"http:\/\/local.yahoo.com\/mapview?stx=Japanese+Restuarants&csz=Sunnyvale%2C+CA&city=Sunnyvale&state=CA&radius=15&ed=jnZFc6131DzZTzp6nJ.Sj0vP6r0PvlDG8RNzNtQ6tFHuGw--","Result":[{"Title":"Rokko Japanese Restaurant","Address":"190 S Frances St","City":"Sunnyvale","State":"CA","Phone":"(408) 732-7550","Latitude":"37.376391","Longitude":"-122.031247","Rating":{"AverageRating":"4.5","TotalRatings":"16","TotalReviews":"10","LastReviewDate":"1168830681"},"Distance":"0.44","Url":"http:\/\/local.yahoo.com\/details?id=21337854&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=k88ULK160SwkcTlxdEr08KiA8mWpnD.jSzV9TEQMFtltP1edHS4EETOZcU08O4NOs9cg6tSaCNQ-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21337854&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=k88ULK160SwkcTlxdEr08KiA8mWpnD.jSzV9TEQMFtltP1edHS4EETOZcU08O4NOs9cg6tSaCNQ-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Rokko+Japanese+Restaurant&desc=4087327550&csz=Sunnyvale+CA&qty=9&cs=9&ed=k88ULK160SwkcTlxdEr08KiA8mWpnD.jSzV9TEQMFtltP1edHS4EETOZcU08O4NOs9cg6tSaCNQ-&gid1=21337854","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Tanto Japanese Restaurant","Address":"1063 E El Camino Real","City":"Sunnyvale","State":"CA","Phone":"(408) 244-7311","Latitude":"37.352437","Longitude":"-122.003985","Rating":{"AverageRating":"4.5","TotalRatings":"18","TotalReviews":"13","LastReviewDate":"1166249857"},"Distance":"1.74","Url":"http:\/\/local.yahoo.com\/details?id=28758486&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=pqfMya160SxLDciSCbxi80wYI0pgpD3NRyyyRTBNA6FNLQ4JFbRw8PLoKVhZk5fAuVPS9oJ9kBoPRzedLQ--","ClickUrl":"http:\/\/local.yahoo.com\/details?id=28758486&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=pqfMya160SxLDciSCbxi80wYI0pgpD3NRyyyRTBNA6FNLQ4JFbRw8PLoKVhZk5fAuVPS9oJ9kBoPRzedLQ--","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Tanto+Japanese+Restaurant&desc=4082447311&csz=Sunnyvale+CA&qty=9&cs=9&ed=pqfMya160SxLDciSCbxi80wYI0pgpD3NRyyyRTBNA6FNLQ4JFbRw8PLoKVhZk5fAuVPS9oJ9kBoPRzedLQ--&gid1=28758486","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Andoh Japanese Restaurant","Address":"161 S Sunnyvale Ave","City":"Sunnyvale","State":"CA","Phone":"(408) 739-0222","Latitude":"37.376454","Longitude":"-122.029359","Rating":{"AverageRating":"4","TotalRatings":"3","TotalReviews":"3","LastReviewDate":"1151053228"},"Distance":"0.44","Url":"http:\/\/local.yahoo.com\/details?id=21340827&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=cU02EK160SwMm7E_Xm5dN_bJ_dN67_4hFws.KxU6ULTRiYYTGlG0EoMCA3p1bb2_ZwAt5GeK255SgHQ-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21340827&stx=Japanese+Restuarants&csz=Sunnyvale+CA&ed=cU02EK160SwMm7E_Xm5dN_bJ_dN67_4hFws.KxU6ULTRiYYTGlG0EoMCA3p1bb2_ZwAt5GeK255SgHQ-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Andoh+Japanese+Restaurant&desc=4087390222&csz=Sunnyvale+CA&qty=9&cs=9&ed=cU02EK160SwMm7E_Xm5dN_bJ_dN67_4hFws.KxU6ULTRiYYTGlG0EoMCA3p1bb2_ZwAt5GeK255SgHQ-&gid1=21340827","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Dashi Japanese Restaurant","Address":"873 Hamilton Ave","City":"Menlo Park","State":"CA","Phone":"(650) 328-6868","Latitude":"37.479737","Longitude":"-122.152176","Rating":{"AverageRating":"4","TotalRatings":"5","TotalReviews":"4","LastReviewDate":"1160472255"},"Distance":"8.95","Url":"http:\/\/local.yahoo.com\/details?id=21296895&stx=Japanese+Restuarants&csz=Menlo+Park+CA&ed=2DF.7K160SwvgQlp9OCvGZECfgceyrk_gsoiYt8ZefQIuCbCjWohAGpG97fMP0ERF8bYQCXRMSA-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21296895&stx=Japanese+Restuarants&csz=Menlo+Park+CA&ed=2DF.7K160SwvgQlp9OCvGZECfgceyrk_gsoiYt8ZefQIuCbCjWohAGpG97fMP0ERF8bYQCXRMSA-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Dashi+Japanese+Restaurant&desc=6503286868&csz=Menlo+Park+CA&qty=9&cs=9&ed=2DF.7K160SwvgQlp9OCvGZECfgceyrk_gsoiYt8ZefQIuCbCjWohAGpG97fMP0ERF8bYQCXRMSA-&gid1=21296895","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Yakko Japanese Restaurant","Address":"975 W Dana St","City":"Mountain View","State":"CA","Phone":"(650) 960-0626","Latitude":"37.393149","Longitude":"-122.081723","Rating":{"AverageRating":"4","TotalRatings":"20","TotalReviews":"13","LastReviewDate":"1151212600"},"Distance":"2.73","Url":"http:\/\/local.yahoo.com\/details?id=21322910&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=sl.tma160SwK9Kbeo22P2GZAAMjNzvxj9A04VCrMtoOpdLjbPhkK9jn6jrcVvDs.RUnXjNw-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21322910&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=sl.tma160SwK9Kbeo22P2GZAAMjNzvxj9A04VCrMtoOpdLjbPhkK9jn6jrcVvDs.RUnXjNw-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Yakko+Japanese+Restaurant&desc=6509600626&csz=Mountain+View+CA&qty=9&cs=9&ed=sl.tma160SwK9Kbeo22P2GZAAMjNzvxj9A04VCrMtoOpdLjbPhkK9jn6jrcVvDs.RUnXjNw-&gid1=21322910","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Kobe Japanese Restaurant","Address":"2086 El Camino Real","City":"Santa Clara","State":"CA","Phone":"(408) 984-5623","Latitude":"37.352263","Longitude":"-121.960986","Rating":{"AverageRating":"4","TotalRatings":"14","TotalReviews":"11","LastReviewDate":"1167701177"},"Distance":"3.73","Url":"http:\/\/local.yahoo.com\/details?id=21575480&stx=Japanese+Restuarants&csz=Santa+Clara+CA&ed=SqnRDa160SxAuBBFwVP_g4s7yXbRTyr8cDejcIzgUrO1NxM7K78wQ4olXhDfIQo2E9t1HmchmmPKehA-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21575480&stx=Japanese+Restuarants&csz=Santa+Clara+CA&ed=SqnRDa160SxAuBBFwVP_g4s7yXbRTyr8cDejcIzgUrO1NxM7K78wQ4olXhDfIQo2E9t1HmchmmPKehA-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Kobe+Japanese+Restaurant&desc=4089845623&csz=Santa+Clara+CA&qty=9&cs=9&ed=SqnRDa160SxAuBBFwVP_g4s7yXbRTyr8cDejcIzgUrO1NxM7K78wQ4olXhDfIQo2E9t1HmchmmPKehA-&gid1=21575480","BusinessUrl":"http:\/\/www.kobesushi.com\/","BusinessClickUrl":"http:\/\/www.kobesushi.com\/"},{"Title":"Tomokazu Japanese Cuisine","Address":"20625 Alves Dr","City":"Cupertino","State":"CA","Phone":"(408) 863-0168","Latitude":"37.325237","Longitude":"-122.034226","Rating":{"AverageRating":"4.5","TotalRatings":"2","TotalReviews":"0"},"Distance":"2.73","Url":"http:\/\/local.yahoo.com\/details?id=21569274&stx=Japanese+Restuarants&csz=Cupertino+CA&ed=XjBQna160Swr0hgTKj1k5hC5YKOk_zXl3eGjbD5EDG7hQStvNnfMnrluMB7l0GUSRcEU0CbN","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21569274&stx=Japanese+Restuarants&csz=Cupertino+CA&ed=XjBQna160Swr0hgTKj1k5hC5YKOk_zXl3eGjbD5EDG7hQStvNnfMnrluMB7l0GUSRcEU0CbN","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Tomokazu+Japanese+Cuisine&desc=4088630168&csz=Cupertino+CA&qty=9&cs=9&ed=XjBQna160Swr0hgTKj1k5hC5YKOk_zXl3eGjbD5EDG7hQStvNnfMnrluMB7l0GUSRcEU0CbN&gid1=21569274","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Ariake Japanese Restaurant","Address":"5190 Stevens Creek Blvd","City":"San Jose","State":"CA","Phone":"(408) 249-8383","Latitude":"37.322924","Longitude":"-121.993611","Rating":{"AverageRating":"4","TotalRatings":"5","TotalReviews":"3","LastReviewDate":"1151715162"},"Distance":"3.42","Url":"http:\/\/local.yahoo.com\/details?id=21617248&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=m7NFha160Sypo8wRot.xksKzjK6AOqFr62lRfvDHX3S3BqC6mvIM0t_RD2KDxfhK8TKQ41UGgR1mKW7JxBGH","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21617248&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=m7NFha160Sypo8wRot.xksKzjK6AOqFr62lRfvDHX3S3BqC6mvIM0t_RD2KDxfhK8TKQ41UGgR1mKW7JxBGH","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Ariake+Japanese+Restaurant&desc=4082498383&csz=San+Jose+CA&qty=9&cs=9&ed=m7NFha160Sypo8wRot.xksKzjK6AOqFr62lRfvDHX3S3BqC6mvIM0t_RD2KDxfhK8TKQ41UGgR1mKW7JxBGH&gid1=21617248","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Akane Japanese Restaurant","Address":"250 3rd St","City":"Los Altos","State":"CA","Phone":"(650) 941-8150","Latitude":"37.378956","Longitude":"-122.11594","Rating":{"AverageRating":"4","TotalRatings":"6","TotalReviews":"5","LastReviewDate":"1172463639"},"Distance":"4.04","Url":"http:\/\/local.yahoo.com\/details?id=21303851&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=XK8Hxa160Sw6UTCPEbjHYYznustfVpPRWoQxQLgkgTpM50WY9gVQAZ89PmuP0Zr9ig--","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21303851&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=XK8Hxa160Sw6UTCPEbjHYYznustfVpPRWoQxQLgkgTpM50WY9gVQAZ89PmuP0Zr9ig--","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Akane+Japanese+Restaurant&desc=6509418150&csz=Los+Altos+CA&qty=9&cs=9&ed=XK8Hxa160Sw6UTCPEbjHYYznustfVpPRWoQxQLgkgTpM50WY9gVQAZ89PmuP0Zr9ig--&gid1=21303851","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Kikusushi Japanese Restaurant","Address":"1295 Kentwood Ave","City":"San Jose","State":"CA","Phone":"(408) 725-1749","Latitude":"37.303802","Longitude":"-122.032547","Rating":{"AverageRating":"4.5","TotalRatings":"9","TotalReviews":"7","LastReviewDate":"1164089003"},"Distance":"4.04","Url":"http:\/\/local.yahoo.com\/details?id=21603486&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=_0YFV6160Sxox4u5z53aTQqyjZeJzhkphzJWq9t3AgarcrpW5lwLoOYJ55vo2_umjjpzYkf7o5mu","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21603486&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=_0YFV6160Sxox4u5z53aTQqyjZeJzhkphzJWq9t3AgarcrpW5lwLoOYJ55vo2_umjjpzYkf7o5mu","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Kikusushi+Japanese+Restaurant&desc=4087251749&csz=San+Jose+CA&qty=9&cs=9&ed=_0YFV6160Sxox4u5z53aTQqyjZeJzhkphzJWq9t3AgarcrpW5lwLoOYJ55vo2_umjjpzYkf7o5mu&gid1=21603486","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Japanese Restaurants Hoshi","Address":"246 Saratoga Ave","City":"Santa Clara","State":"CA","Phone":"(408) 554-7100","Latitude":"37.328911","Longitude":"-121.965282","Rating":{"AverageRating":"5","TotalRatings":"2","TotalReviews":"2","LastReviewDate":"1168310102"},"Distance":"4.16","Url":"http:\/\/local.yahoo.com\/details?id=32304430&stx=Japanese+Restuarants&csz=Santa+Clara+CA&ed=U.Zf7q160SygKK1ELX7l2uomjhC6w30fxUEa8d3pzlsIh07QEb75XGNhvFXms0htdNACDqrosHU-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=32304430&stx=Japanese+Restuarants&csz=Santa+Clara+CA&ed=U.Zf7q160SygKK1ELX7l2uomjhC6w30fxUEa8d3pzlsIh07QEb75XGNhvFXms0htdNACDqrosHU-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Japanese+Restaurants+Hoshi&desc=4085547100&csz=Santa+Clara+CA&qty=9&cs=9&ed=U.Zf7q160SygKK1ELX7l2uomjhC6w30fxUEa8d3pzlsIh07QEb75XGNhvFXms0htdNACDqrosHU-&gid1=32304430","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Kitahama Japanese Restaurant","Address":"974 S De Anza Blvd","City":"San Jose","State":"CA","Phone":"(408) 257-6449","Latitude":"37.310627","Longitude":"-122.031926","Rating":{"AverageRating":"5","TotalRatings":"1","TotalReviews":"1","LastReviewDate":"1151053228"},"Distance":"3.60","Url":"http:\/\/local.yahoo.com\/details?id=21619341&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=aX7Hza160Swa4QRUjJWEmaWxFRCjXwIRnoID2Mrpah5PqGsO97igSaZ4khdGsqHAnzwRLW3cBw0vwQ--","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21619341&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=aX7Hza160Swa4QRUjJWEmaWxFRCjXwIRnoID2Mrpah5PqGsO97igSaZ4khdGsqHAnzwRLW3cBw0vwQ--","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Kitahama+Japanese+Restaurant&desc=4082576449&csz=San+Jose+CA&qty=9&cs=9&ed=aX7Hza160Swa4QRUjJWEmaWxFRCjXwIRnoID2Mrpah5PqGsO97igSaZ4khdGsqHAnzwRLW3cBw0vwQ--&gid1=21619341","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Midoriya Japanese Restaurant","Address":"1350 Grant Rd","City":"Mountain View","State":"CA","Phone":"(650) 964-8535","Latitude":"37.377109","Longitude":"-122.075697","Rating":{"AverageRating":"","TotalRatings":"0","TotalReviews":"0"},"Distance":"2.05","Url":"http:\/\/local.yahoo.com\/details?id=21320764&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=Suh8Ba160SwCwkA42mTXjqkxhlUCiHloq_k2bgDb9xvMwo0hjN799kyPP7bfw.KTGYTbpk0-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21320764&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=Suh8Ba160SwCwkA42mTXjqkxhlUCiHloq_k2bgDb9xvMwo0hjN799kyPP7bfw.KTGYTbpk0-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Midoriya+Japanese+Restaurant&desc=6509648535&csz=Mountain+View+CA&qty=9&cs=9&ed=Suh8Ba160SwCwkA42mTXjqkxhlUCiHloq_k2bgDb9xvMwo0hjN799kyPP7bfw.KTGYTbpk0-&gid1=21320764","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Rin Japanese Restaurant","Address":"244 State St","City":"Los Altos","State":"CA","Phone":"(650) 948-6767","Latitude":"37.379351","Longitude":"-122.11672","Rating":{"AverageRating":"","TotalRatings":"0","TotalReviews":"0"},"Distance":"4.04","Url":"http:\/\/local.yahoo.com\/details?id=21299798&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=Aldv3K160Sz10DbwJTEC6rfNtoGgmW3KXIYuE.3JoA95nX5hEQmWn7Ja5O9f4JxxnCsh","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21299798&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=Aldv3K160Sz10DbwJTEC6rfNtoGgmW3KXIYuE.3JoA95nX5hEQmWn7Ja5O9f4JxxnCsh","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Rin+Japanese+Restaurant&desc=6509486767&csz=Los+Altos+CA&qty=9&cs=9&ed=Aldv3K160Sz10DbwJTEC6rfNtoGgmW3KXIYuE.3JoA95nX5hEQmWn7Ja5O9f4JxxnCsh&gid1=21299798","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Mikado Japanese Restaurant","Address":"161 Main St","City":"Los Altos","State":"CA","Phone":"(650) 917-8388","Latitude":"37.379478","Longitude":"-122.11514","Rating":{"AverageRating":"4.5","TotalRatings":"3","TotalReviews":"2","LastReviewDate":"1156651631"},"Distance":"3.98","Url":"http:\/\/local.yahoo.com\/details?id=21300759&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=.vCy4q160SzWn8wuuocPdZcaZb.TZQz_2fyxAt53lAF.yY.kBuIfskTJ9Pk7GjaEnYo-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21300759&stx=Japanese+Restuarants&csz=Los+Altos+CA&ed=.vCy4q160SzWn8wuuocPdZcaZb.TZQz_2fyxAt53lAF.yY.kBuIfskTJ9Pk7GjaEnYo-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Mikado+Japanese+Restaurant&desc=6509178388&csz=Los+Altos+CA&qty=9&cs=9&ed=.vCy4q160SzWn8wuuocPdZcaZb.TZQz_2fyxAt53lAF.yY.kBuIfskTJ9Pk7GjaEnYo-&gid1=21300759","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Tanto Japanese Restaurant","Address":"1306 Saratoga Ave","City":"San Jose","State":"CA","Phone":"(408) 249-6020","Latitude":"37.300611","Longitude":"-121.981746","Rating":{"AverageRating":"4.5","TotalRatings":"11","TotalReviews":"8","LastReviewDate":"1162619243"},"Distance":"4.91","Url":"http:\/\/local.yahoo.com\/details?id=21603494&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=3CFHuK160SypAyZ8muh6XQQNat_.siwVnIoyfoioOcz.TsTLiU_gibrQBvI6zALWTpQQAvcqD55h","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21603494&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=3CFHuK160SypAyZ8muh6XQQNat_.siwVnIoyfoioOcz.TsTLiU_gibrQBvI6zALWTpQQAvcqD55h","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Tanto+Japanese+Restaurant&desc=4082496020&csz=San+Jose+CA&qty=9&cs=9&ed=3CFHuK160SypAyZ8muh6XQQNat_.siwVnIoyfoioOcz.TsTLiU_gibrQBvI6zALWTpQQAvcqD55h&gid1=21603494","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Furu-Sato Japanese Restaurant","Address":"1651 W Campbell Ave","City":"Campbell","State":"CA","Phone":"(408) 370-1300","Latitude":"37.286163","Longitude":"-121.978879","Rating":{"AverageRating":"4.5","TotalRatings":"6","TotalReviews":"4","LastReviewDate":"1164343826"},"Distance":"5.78","Url":"http:\/\/local.yahoo.com\/details?id=21562700&stx=Japanese+Restuarants&csz=Campbell+CA&ed=1DnT56160SzoM8vkLUtBrkkzQ5wuxEUA.K6.Qt2j4HGWnRr4D4jc_EZewYhEjBkqH3Ez9N4dQnTG01g-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21562700&stx=Japanese+Restuarants&csz=Campbell+CA&ed=1DnT56160SzoM8vkLUtBrkkzQ5wuxEUA.K6.Qt2j4HGWnRr4D4jc_EZewYhEjBkqH3Ez9N4dQnTG01g-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Furu-Sato+Japanese+Restaurant&desc=4083701300&csz=Campbell+CA&qty=9&cs=9&ed=1DnT56160SzoM8vkLUtBrkkzQ5wuxEUA.K6.Qt2j4HGWnRr4D4jc_EZewYhEjBkqH3Ez9N4dQnTG01g-&gid1=21562700","BusinessUrl":"http:\/\/furu-sato.com\/","BusinessClickUrl":"http:\/\/furu-sato.com\/"},{"Title":"Miyabitei Japanese Restaurant","Address":"675 Saratoga Ave","City":"San Jose","State":"CA","Phone":"(408) 252-5010","Latitude":"37.314809","Longitude":"-121.976788","Rating":{"AverageRating":"","TotalRatings":"0","TotalReviews":"0"},"Distance":"4.35","Url":"http:\/\/local.yahoo.com\/details?id=21613017&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=U.pKOK160Sw9qLA4mb0xPD1kVIZb2QsCYxPdsqvtQ.9E8bk47wlC91bIJbq34hMsRQxfQt3AE2k-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21613017&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=U.pKOK160Sw9qLA4mb0xPD1kVIZb2QsCYxPdsqvtQ.9E8bk47wlC91bIJbq34hMsRQxfQt3AE2k-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Miyabitei+Japanese+Restaurant&desc=4082525010&csz=San+Jose+CA&qty=9&cs=9&ed=U.pKOK160Sw9qLA4mb0xPD1kVIZb2QsCYxPdsqvtQ.9E8bk47wlC91bIJbq34hMsRQxfQt3AE2k-&gid1=21613017","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Niko Japanese Restaurant","Address":"1035 S Winchester Blvd","City":"San Jose","State":"CA","Phone":"(408) 260-0255","Latitude":"37.308043","Longitude":"-121.950172","Rating":{"AverageRating":"5","TotalRatings":"4","TotalReviews":"2","LastReviewDate":"1159757931"},"Distance":"5.53","Url":"http:\/\/local.yahoo.com\/details?id=21604539&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=pyBF3q160SyPYyh8HmiDb2RwcjYeLQ_1ySQQ_zA1gf24q9XLZix8K.XJDVZeISb0LN2CwID_wXKMnoQzHJk-","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21604539&stx=Japanese+Restuarants&csz=San+Jose+CA&ed=pyBF3q160SyPYyh8HmiDb2RwcjYeLQ_1ySQQ_zA1gf24q9XLZix8K.XJDVZeISb0LN2CwID_wXKMnoQzHJk-","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Niko+Japanese+Restaurant&desc=4082600255&csz=San+Jose+CA&qty=9&cs=9&ed=pyBF3q160SyPYyh8HmiDb2RwcjYeLQ_1ySQQ_zA1gf24q9XLZix8K.XJDVZeISb0LN2CwID_wXKMnoQzHJk-&gid1=21604539","BusinessUrl":"","BusinessClickUrl":""},{"Title":"Satsuma Restaurant","Address":"705 E El Camino Real","City":"Mountain View","State":"CA","Phone":"(650) 966-1122","Latitude":"37.377086","Longitude":"-122.065054","Rating":{"AverageRating":"4","TotalRatings":"12","TotalReviews":"8","LastReviewDate":"1164247452"},"Distance":"1.55","Url":"http:\/\/local.yahoo.com\/details?id=21315459&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=YNU5hK160SykXqCP3nRNVl5LanLaj2ISqM8RJCJRk.Md8hZBnc_8yelVV3O5K3UqrshxlSA9CfS55wsg","ClickUrl":"http:\/\/local.yahoo.com\/details?id=21315459&stx=Japanese+Restuarants&csz=Mountain+View+CA&ed=YNU5hK160SykXqCP3nRNVl5LanLaj2ISqM8RJCJRk.Md8hZBnc_8yelVV3O5K3UqrshxlSA9CfS55wsg","MapUrl":"http:\/\/maps.yahoo.com\/maps_result?name=Satsuma+Restaurant&desc=6509661122&csz=Mountain+View+CA&qty=9&cs=9&ed=YNU5hK160SykXqCP3nRNVl5LanLaj2ISqM8RJCJRk.Md8hZBnc_8yelVV3O5K3UqrshxlSA9CfS55wsg&gid1=21315459","BusinessUrl":"","BusinessClickUrl":""}]}}'
);

my $type = Dict[
    ResultSet => Dict[
        totalResultsAvailable => Num,
        totalResultsReturned => Num,
        firstResultPosition => Num,
        ResultSetMapUrl => Str,
        Result => ArrayRef[
            Dict[
                Title => Str,
                Address => Str,
                City => Str,
                State => Str,
                Phone => Str,
                Latitude => Str,
                Longitude => Str,
                Rating => Dict[
                    AverageRating => Str,
                    TotalRatings => Str,
                    TotalReviews => Str,
                    LastReviewDate => Optional[Str],
                ],
                Distance => Str,
                Url => Str,
                ClickUrl => Str,
                MapUrl => Str,
                BusinessUrl => Str,
                BusinessClickUrl => Str,
            ]
        ]
    ]
];

my $jsont = JSON::TypeEncoder->new;
my $encode = $jsont->encoder($type);

cmpthese -1, {
    'JSON::XS'          => sub { JSON::XS::encode_json($data) },
    'JSON::PP'          => sub { JSON::PP::encode_json($data) },
    'JSON::TypeEncoder' => sub { $encode->($data) },
};

#                      Rate          JSON::PP          JSON::XS JSON::TypeEncoder
# JSON::PP            984/s                --              -96%              -97%
# JSON::XS          26946/s             2639%                --              -13%
# JSON::TypeEncoder 30919/s             3043%               15%                --
