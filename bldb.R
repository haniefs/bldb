print("===================================================")
print("<<start log>>")
print(substr(Sys.time(),1,19))
library(Rblpapi)
library(RMySQL)

con<-blpConnect()
bldb = dbConnect(MySQL(), user='', password='', dbname='', host='')
query<-dbGetQuery(bldb, "SELECT id_tickers, securities, fields FROM tickers")
dbDisconnect(bldb)

bldb = dbConnect(MySQL(), user='', password='', dbname='', host='')
id_exists<-dbGetQuery(bldb, "SELECT id_tickers FROM px_update")
dbDisconnect(bldb)

print("===================================================")
for(i in 1:nrow(query)) {
  row<-query[i,1:3]
  id_tickers<-row[[1]]
  
  bldb = dbConnect(MySQL(), user='', password='', dbname='', host='')
  qqq<-paste("SELECT last_update FROM px_update WHERE id_tickers=",id_tickers, sep="")
  last_update<-dbGetQuery(bldb, qqq)
  last_update<-gsub("-","",last_update)
  dbDisconnect(bldb)
  
  securities<-row[[2]]
  fields<-row[[3]]
  tick<-paste(securities, fields)
  securities<-gsub(" ","_",securities)
  lsecurities<-tolower(securities)
  start.date<-substr(Sys.time(),1,19)
  bldata = bdh(tick, "PX_LAST", as.Date(start.date),  options = c("nonTradingDayFillOption"="ALL_CALENDAR_DAYS"))
  bldata = bldata[order(as.Date(bldata$date, format="%Y-%m-%d"), decreasing = TRUE),]
  
  tanggal <- bldata[[1,1]]								    # ambil tanggal dari bldata [[1,1]] biar output ga vector. gila nih R rempong
  tahun <- substr(tanggal,1,4)							  # rapihin format tanggal biar ga ditolak mysql
  bulan <- substr(tanggal,6,7)							  # sama kaya atas
  hari <- substr(tanggal,9,10)							  # masih sama kaya atas
  time <- substr(Sys.time(),12,19)            # sumpah masih sama kaya yang atas!!!!!
  tanggal <- paste(tahun,bulan,hari, sep="")  # ilangin spasi dari var tanggal biar diterima mysql dengan lapang dada
  tanggaljam <- paste(tanggal,time)           # bikin timestamp buat update jam-jaman. hehe jam-jaman. kaya apa gitu LOL
  tanggaljam <- gsub(":","",tanggaljam)       # ilangin : dari format jam
  tanggaljam <- gsub(" ","",tanggaljam)       # ilangin spasi dari format jam biar ga ditolak mysql :*
  px_last <- bldata[[2]]								      # ambil nilai px_last
  
  

  haha<-paste(bldata[[1,2]])
  asd<-paste(securities,"=",haha)
  
if (haha!="NA") {
  
  bldbi = dbConnect(MySQL(), user='', password='', dbname='', host='')
  if (!(id_tickers %in% id_exists$id_tickers)) {
    queryi <- paste("INSERT INTO px_update (id_tickers, timestamp, px_last, last_update) VALUES (", id_tickers,",",tanggaljam,",",px_last,",",tanggal,")", sep="")
    dbGetQuery(bldbi, queryi)
  }else{
    queryi <- paste("UPDATE px_update SET timestamp=",tanggaljam,", px_last=",px_last,", last_update=",tanggal," WHERE id_tickers=",id_tickers, sep="")
    dbGetQuery(bldbi, queryi)
  }
  
  bldbb = dbConnect(MySQL(), user='', password='', dbname='', host='')
  quehehe <- paste("SELECT tanggal FROM" ,lsecurities, "ORDER BY tanggal DESC LIMIT 1")
  lupdate<-dbGetQuery(bldbb, quehehe)
  dbDisconnect(bldbb)
  lupdate<-gsub("-","",lupdate)
  
  if(lupdate==tanggal){
    queryii <- paste("UPDATE ",lsecurities," SET px_last=",px_last," WHERE tanggal=",tanggal, sep="")
  }else{
    queryii <- paste("INSERT into ",lsecurities," (tanggal, px_last) VALUES (",tanggal,",",px_last,")", sep="")
  }
  dbGetQuery(bldbi, queryii)
  dbDisconnect(bldbi)
  asd<-paste(asd,"(masuk db)")
  print(asd)
}else{
  asd<-paste(asd,"(abaikan)")
  print(asd)
}
}
print("NKRI AMAN TERKENDALI")
print("<<end log>>")
Sys.sleep(7)
