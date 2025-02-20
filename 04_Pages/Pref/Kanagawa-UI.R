fluidPage(
  fluidRow(
    column(width = 6, style='padding:0px;',
           widgetUserBox(
             title = '神奈川県', 
             subtitle = '関東地方', 
             width = 12,
             type = 2, 
             color = 'aqua-active',
             collapsible = F,
             paste0('こちらは神奈川県の発生状況をまとめたページです。', 
                    '厚労省のまとめより早く状況を把握できますが、',
                    '県の集計時間は厚労省の発表時間と完全に一致していないため、', 
                    'タイムラグによる数値の違いが生じる可能性もありますので、予めご注意ください。',
                    'また、速報では陰性から再び陽性になった人は再計算に含めていないため、自治体発表の陽性者数と数値が異なる場合があります。'
             ),
             footer = tagList(
               tags$small(icon('database'),
                          tags$a(href = 'https://www.pref.kanagawa.jp/osirase/1369/',
                                 '感染症対策サイト'),
                          icon('database'),
                          tags$a(href = 'https://signate.jp/competitions/260/discussions', 
                                 'COVID-19 Chanllenge'),
                          icon('newspaper'),
                          tags$a(href = 'https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html',
                                 '厚生労働省'),
                          icon('twitter'),
                          tags$a(href = 'https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html',
                                 '@kenmo_economics')
               )
             )
           )
    ),
    column(width = 6,
           uiOutput('kanagawaValueBoxes') %>% withSpinner(proxy.height = '200px')
    )
  ),
  fluidRow(
    boxPlus(
      width = 12, 
      title = tagList(icon('chart-line'), '神奈川県の発生状況'),
      closable = F,
      fluidRow(
        column(
          width = 6,
          echarts4rOutput('kanagawaContact') %>% withSpinner()
        ),
        column(
          width = 6,
          echarts4rOutput('kanagawaPatientSummary') %>% withSpinner()
        )
      ),
      footer = tags$small(icon('lightbulb'), i18n$t("凡例クリックすると表示・非表示の切替ができます。"))
    )
  ),
  fluidRow(
    boxPlus(
      width = 12,
      closable = F, 
      collapsed = T, 
      collapsible = T,
      enable_label = T, 
      label_text = tagList('クリックして', icon('hand-point-right')), 
      label_status = 'warning',
      title = tagList(icon('map-marked-alt'), '県内の感染者')
      # fluidRow(
      #   column(
      #     width = 8,
      #     leafletOutput('hokkaidoConfirmedMap', height = '500px') %>% withSpinner(),
      #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   ),
      #   column(
      #     width = 4,
      #     uiOutput('hokkaidoProfile') %>% withSpinner()
      #   )
      # )# ,
      # fluidRow(
      #   column(
      #     width = 8,
      #     dataTableOutput('hokkaidoPatientTable') %>% withSpinner(),
      #   )
      # )
    )
  )
)