# library(gtools)
# library(data.table)
# 
# 統合部分 =====
# pcrByRegion <- fread(file = paste0(DATA_PATH, "MHLW/pcrByRegion.csv"))
# 
# detailByRegion <- fread(paste0(DATA_PATH, "detailByRegion.csv"))
# detailByRegion[, 都道府県名 := gsub("県|府", "", 都道府県名)]
# detailByRegion[, 都道府県名 := gsub("東京都", "東京", 都道府県名)]
# 
# detailByRegion[pcrByRegion, 検査人数 := i.検査人数, on = c(都道府県名 = "都道府県略称", 日付 = "日付")]
# detailByRegion$日付 <- as.character(detailByRegion$日付)
# names(detailByRegion) <- c("日付", "都道府県名", "陽性者", "入院中", "退院者", "死亡者", "検査人数")
# 
# location <- list("20200509" = "https://www.mhlw.go.jp/content/10906000/000628667.pdf")
# 
# out <- extract_tables(location[1][[1]], method = "lattice")
# 
# dt <- data.table(out[[1]])
# colnames(dt) <- c("都道府県名", "陽性者", "検査人数", "入院中", "重症者", "退院者", "死亡者")
# dt <- dt[3:(nrow(dt) - 1)]
# dt[grepl("その他", 都道府県名), 都道府県名 := "伊客船"]
# dt[, 都道府県名 := gsub(" ", "", 都道府県名)]
# cols <- colnames(dt)[2:ncol(dt)]
# dt[, (cols) := lapply(.SD, function(x){return(gsub(",", "", x))}), .SDcols = cols]
# suppressWarnings(dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])
# dt$temp <- rowSums(dt[, c(4, 6:ncol(dt)), with = F], na.rm = T)
# dt[, 確認中 := 陽性者 - temp]
# 
# dt[, temp := NULL]
# dt <- cbind(data.table("日付" = rep(names(location[1]), nrow(dt))), dt)
# 
# dataset<- smartbind(detailByRegion, dt)
# dataset <- data.table(dataset)
# 
# # fwrite(dataset, file = "50_Data/MHLW/summary.csv")
# 
# airportDailyReport <- fread(paste0(DATA_PATH, "airportDailyReport.csv"))
# flightDailyReport <- fread(paste0(DATA_PATH, "flightDailyReport.csv"))
# shipDailyReport <- fread(paste0(DATA_PATH, "shipDailyReport.csv"))
# 
# ConvertDailyReport <- function(data, type) {
#   return(data[, .(
#     日付  = as.character(date),
#     都道府県名 = type,
#     陽性者  = positive,
#     入院中  = hospitalized, # hospitalize,
#     退院者  = discharge,
#     重症者  = severe,
#     死亡者  = death,
#     検査人数  = pcr,
#     確認中  = confirming
#   )])
# }
# 
# airport <- ConvertDailyReport(airportDailyReport, "空港検疫")
# flight <- ConvertDailyReport(flightDailyReport, "チャーター便")
# 
# ship <- shipDailyReport[, .(日付 = as.character(date),
#                       都道府県名 = "クルーズ船",
#                       陽性者  = positive,
#                       退院者  = discharge,
#                       重症者  = severe,
#                       死亡者  = death,
#                       検査人数  = pcr,
#                       確認中 = positive - discharge - severe - death - 40
#                       )]
# 
# dataset <- smartbind(dataset, airport, flight, ship)
# 
# provinceCode <- fread(paste0(DATA_PATH, "prefectures.csv"))
# code <- c(sprintf("%02d", provinceCode$id), 48:51)
# codeName <- c(provinceCode$`name-ja`, "伊客船", "空港検疫", "チャーター便", "クルーズ船")
# names(codeName) <- code
# 
# dataset$id <- names(codeName[match(dataset$都道府県名, codeName)])
# dataset <- data.table(dataset)
# dataset <- dataset[order(日付, id)]
# dataset <- dataset[,.(日付, 都道府県名, 陽性者, 検査人数, 入院中, 重症者, 退院者, 死亡者, 確認中)]
# fwrite(dataset, file = "50_Data/MHLW/summary.csv")
# dataset <- fread(file = "50_Data/MHLW/summary.csv")
# dataset[都道府県名 == "空港検疫", 分類 := 1]
# dataset[都道府県名 == "チャーター便", 分類 := 2]
# dataset[都道府県名 == "クルーズ船", 分類 := 3]
# dataset[is.na(分類), 分類 := 0]
# fwrite(dataset, file = "50_Data/MHLW/summary.csv")

# 更新部分 =====
# library(tabulizer)
# library(gtools)
# library(data.table)
# 
# dataset <- fread(file = "50_Data/MHLW/summary.csv")
# location <- list(
#   "20200509" = "https://www.mhlw.go.jp/content/10906000/000628667.pdf",
#   "20200510" = "https://www.mhlw.go.jp/content/10906000/000628697.pdf",
#   "20200511" = "https://www.mhlw.go.jp/content/10906000/000628917.pdf",
#   "20200512" = "https://www.mhlw.go.jp/content/10906000/000629544.pdf",
#   "20200513" = "https://www.mhlw.go.jp/content/10906000/000630162.pdf",
#   "20200514" = "https://www.mhlw.go.jp/content/10906000/000630534.pdf",
#   "20200515" = "https://www.mhlw.go.jp/content/10906000/000630924.pdf",
#   "20200516" = "https://www.mhlw.go.jp/content/10906000/000631063.pdf",
#   "20200517" = "https://www.mhlw.go.jp/content/10906000/000631149.pdf",
#   "20200518" = "https://www.mhlw.go.jp/content/10906000/000631428.pdf",
#   "20200519" = "https://www.mhlw.go.jp/content/10906000/000631887.pdf",
#   "20200520" = "https://www.mhlw.go.jp/content/10906000/000632211.pdf",
#   "20200521" = "https://www.mhlw.go.jp/content/10906000/000632553.pdf",
#   "20200522" = "https://www.mhlw.go.jp/content/10906000/000632894.pdf",
#   "20200523" = "https://www.mhlw.go.jp/content/10906000/000633030.pdf",
#   "20200524" = "https://www.mhlw.go.jp/content/10906000/000633053.pdf",
#   "20200525" = "https://www.mhlw.go.jp/content/10906000/000633317.pdf",
#   "20200526" = "https://www.mhlw.go.jp/content/10906000/000633684.pdf",
#   "20200527" = "https://www.mhlw.go.jp/content/10906000/000634251.pdf",
#   "20200528" = "https://www.mhlw.go.jp/content/10906000/000634785.pdf",
#   "20200529" = "https://www.mhlw.go.jp/content/10906000/000635194.pdf",
#   "20200530" = "https://www.mhlw.go.jp/content/10906000/000635510.pdf",
#   "20200531" = "https://www.mhlw.go.jp/content/10906000/000635537.pdf",
#   "20200601" = "https://www.mhlw.go.jp/content/10906000/000635775.pdf",
#   "20200602" = "https://www.mhlw.go.jp/content/10906000/000636131.pdf",
#   "20200603" = "https://www.mhlw.go.jp/content/10906000/000636580.pdf",
#   "20200604" = "https://www.mhlw.go.jp/content/10906000/000636974.pdf",
#   "20200605" = "https://www.mhlw.go.jp/content/10906000/000637373.pdf",
#   "20200606" = "https://www.mhlw.go.jp/content/10906000/000637517.pdf",
#   "20200607" = "https://www.mhlw.go.jp/content/10906000/000637546.pdf",
#   "20200608" = "https://www.mhlw.go.jp/content/10906000/000637898.pdf",
#   "20200609" = "https://www.mhlw.go.jp/content/10906000/000638331.pdf",
#   "20200610" = "https://www.mhlw.go.jp/content/10906000/000638689.pdf",
#   "20200611" = "https://www.mhlw.go.jp/content/10906000/000638963.pdf",
#   "20200612" = "https://www.mhlw.go.jp/content/10906000/000639340.pdf",
#   "20200613" = "https://www.mhlw.go.jp/content/10906000/000639746.pdf",
#   "20200614" = "https://www.mhlw.go.jp/content/10906000/000639768.pdf",
#   "20200615" = "https://www.mhlw.go.jp/content/10906000/000640012.pdf",
#   "20200616" = "https://www.mhlw.go.jp/content/10906000/000640391.pdf",
#   "20200617" = "https://www.mhlw.go.jp/content/10906000/000640744.pdf",
#   "20200618" = "https://www.mhlw.go.jp/content/10906000/000641279.pdf",
#   "20200619" = "https://www.mhlw.go.jp/content/10906000/000641749.pdf",
#   "20200620" = "https://www.mhlw.go.jp/content/10906000/000641953.pdf",
#   "20200621" = "https://www.mhlw.go.jp/content/10906000/000641965.pdf",
#   "20200622" = "https://www.mhlw.go.jp/content/10906000/000642110.pdf",
#   "20200623" = "https://www.mhlw.go.jp/content/10906000/000642429.pdf"
# )
# 
# for (i in names(location)) {
#   if (!i %in% dataset$日付) {
#     out <- tabulizer::extract_tables(location[i][[1]], method = "lattice")
# 
#     dt <- data.table(out[[1]])
#     # 沖縄処理
#     # dt[49] <- dt[49, c(1:3, 6:7, 10, 13, 4, 5, 8, 9, 11, 12)]
#     # dt[, `:=` (V8 = NULL, V9 = NULL, V10 = NULL, V11 = NULL, V12 = NULL, V13 = NULL)]
# 
#     colnames(dt) <- c("都道府県名", "陽性者", "検査人数", "入院中", "重症者", "退院者", "死亡者")
#     dt <- dt[3:(nrow(dt) - 1)]
#     dt[grepl("その他", 都道府県名), 都道府県名 := "伊客船"]
#     dt[, 都道府県名 := gsub(" ", "", 都道府県名)]
#     cols <- colnames(dt)[2:ncol(dt)]
#     dt[, (cols) := lapply(.SD, function(x){return(gsub(",", "", x))}), .SDcols = cols]
#     suppressWarnings(dt[, (cols) := lapply(.SD, as.numeric), .SDcols = cols])
#     dt$temp <- rowSums(dt[, c(4, 6:ncol(dt)), with = F], na.rm = T)
#     dt[, 確認中 := 陽性者 - temp]
#     dt <- cbind(data.table("日付" = rep(names(location[i]), nrow(dt))), dt, "分類" = 0)
#     dt[, temp := NULL]
#     dataset <- suppressWarnings(gtools::smartbind(dataset, dt))
#   }
# }
# 
# fwrite(dataset, "50_Data/MHLW/summary.csv")
