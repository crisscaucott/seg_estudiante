class ReportePdf < Prawn::Document
  # include PdfUtil
  # require "open-uri"
  # require 'scruffy'
  # include ActionView::Helpers::NumberHelper

  # DATOS DE ESTILO PARA LOS GRAFICOS, COMO COLOR
  GRAPH_STYLE = {background_colors: "transparent", :marker_color => 'black', colors: ['#86c386' ,'#b8e9a1' ,'#f4ffc3','#f5e3ad' ,'#f5cba3' ,'#f2af98' ,'#e88e88']}
  # DATOS DE POSICIONAMIENTO DE LOS GRAFICOS,
  GRAPH_POS = {height: 200, position: :center}
  # CONFIGURACION DE TEXTOS
  TEXT_CONFIG = {inline_format: true, align: :justify, size: 12, style: :normal}
  TEXT_TITLE_CONFIG = {align: :justify, size: 18, style: :bold}
  TEXT_SUBTITLE_CONFIG = {align: :justify, size: 16, style: :bold}
  NO_MESSAGE = "No hay datos suficientes para esta sección."
  TEXT_INDENT = 25
  PADDING = 15
  MONTHS_AGO = 12

  def initialize(options)
    super()

    @num_title = 1
    @num_subtitle = 1
    @carreras = options[:carrera].present? ? Carrera.select([:id, :nombre]).where(id: options[:carrera]) : Carrera.getCarreras()
    @anios_ingreso = options[:anio_ingreso].present? ? [options[:anio_ingreso].to_i] : Date.today.year.downto(Date.today.year - ReporteController::ANIOS_ATRAS).to_a
    @total_estudiantes = []

    @carreras.each do |carrera|
      hash_data = {carrera: carrera.id, anios: []} 
      @anios_ingreso.each do |anio|
        hash_data[:anios] << {anio: anio, total: carrera.estudiantes.where(fecha_ingreso: "#{anio}-01-01"..."#{anio + 1}-01-01").size}
      end
      @total_estudiantes << hash_data
    end

    # @index = {:oferta => {sections: [], page: nil, title: nil, format_title: nil}, :demanda => {sections: [], page: nil, title: nil, format_title: nil}}
    # @stats = statistic
    # @dates = filters.dates
    # @type_of_property = filters.type_of_property
    # @types_names = filters.types_names
    # @modes = filters.mode == 0 ? [1, 2] : filters.mode
    # @currency_id = filters.currency_id
    # currency = Currency.find(@currency_id)
    # @currency_prefix = currency.simbolo_moneda
    # @currency_name = @currency_prefix + " " + currency.nombre
    # @zones_count = @stats.zones(ANY_MODE, ANY_ROOMS, @type_of_property).count
    # @properties_count = @stats.properties(ANY_MODE, ANY_ROOMS, @type_of_property).count
    # @complete_graph = methods[:tipo] == 'completo' ? true : false

    # Agregar fuentes predeterminadas externas.
    # font_families.update("Custom" => {
    #   bold: Rails.root.join('app', 'assets', 'fonts', 'RobotoCondensed-Bold.ttf'),
    #   bold_italic: Rails.root.join('app', 'assets', 'fonts', 'SourceSansPro-Italic.ttf'),
    #   italic: Rails.root.join('app', 'assets', 'fonts', 'RobotoCondensed-LightItalic.ttf'),
    #   normal: Rails.root.join('app', 'assets', 'fonts', 'SourceSansPro-Light.ttf')
    #   })

    header
    titulo
    subtitulo
    intro
    content

    
    # numero de paginas
    number_pages "<page> de <total>",{
      :start_count_at => 1,
      :page_filter => lambda{|pg| pg > 1},  # Solo coloca nº de pagina desde la pagina 3.
      :at => [bounds.right - 50, 0], 
      :align => :right, 
      :size => 10,
      total_pages: page_count - 1
    }
  end

  def header
    #This inserts an image in the pdf file and sets the size of the image
    image "#{Rails.root}/app/assets/images/central.png", height: 40, position: :left
    move_up 35
    time = Time.new
    text "#{time.strftime('%d-%m-%Y')}", align: :right
    move_down 40
  end

  def titulo
    # font "Custom", style: :bold
    text "Reporte", {size: TEXT_TITLE_CONFIG[:size], style: TEXT_TITLE_CONFIG[:style], align: :center}
    move_down 10
    text "Titulo", {size: TEXT_TITLE_CONFIG[:size], style: TEXT_TITLE_CONFIG[:style], align: :center}
    stroke_horizontal_rule
  end

  def subtitulo
    # font "Custom", style: :italic
    move_down 5
    pad_bottom(15) do
      text "subtitulo", size: 14
    end
  end

  def intro
    move_down 50
    # font "Custom", style: :normal
    text "Introduccion", TEXT_CONFIG
  end

  def indice
    start_new_page
    start_new_page
  end

  def content
    @carreras.each do |carrera|
      start_new_page
      desercion_retencion(carrera)
      @num_subtitle += 1

      @num_title += 1
      @num_subtitle = 1
      # puts "Cursor: #{cursor}".green
    end
  end

  # Dibuja la pagina de indice con los contenidos del pdf.
  def buildIndex
    # Ir a la pagina de inicio y colocar el titulo de la pagina.
    go_to_page(2)
    outline.section('Indice', destination: 2)
    
    # Dibujar el header.
    drawHeader

    # Titulo
    pad(PADDING) do
      text 'Indice', {size: TEXT_TITLE_CONFIG[:size], style: TEXT_TITLE_CONFIG[:style], align: :center}
    end

    num_page_title = "Nº de página"
    page_width = width_of(num_page_title, size: TEXT_SUBTITLE_CONFIG[:size], style: TEXT_SUBTITLE_CONFIG[:style]) + 30  # Ancho de las celdas para los nº de pagina
    title_width = bounds.right - (page_width + 60) # Ancho de las celdas para los titulos

    # Encabezado del indice.
    index_titles = [[make_cell(content: "Titulo", align: :left), make_cell(content: num_page_title, align: :center)]]
    table(index_titles, column_widths: [title_width, page_width], position: :center, cell_style: {border_style: :none, borders: [], size: TEXT_SUBTITLE_CONFIG[:size], font_style: TEXT_SUBTITLE_CONFIG[:style], padding: [5,5, PADDING,5]})

    @index.each do |key, value|
      title_content = [] # Se guarda la fila de la tabla con el titulo de oferta o demanda.
      contents = [] # Se guardan cada las fila de los contenidos.
      if value[:sections].size != 0
        title_content.push([make_cell(content: "<link anchor='#{value[:format_title]}'>#{value[:title]}</link>", align: :left, inline_format: true), make_cell((value[:page].to_i - 2).to_s, align: :center)])
        outline.section(key.to_s.capitalize, destination: value[:page]) do
          value[:sections].each do |sub|
            title = sub[:title]
            title += " <b><i> gratis</i></b>" if !sub[:fake] && !@complete_graph
            # Agrega cada seccion al array para el indice.
            contents.push([make_cell(content: "<link anchor='#{sub[:format_title]}'>#{title}</link>", align: :left, inline_format: true), make_cell((sub[:page].to_i - 2).to_s, align: :center)])
            # Agrega una seccion a la tabla de contenidos del pdf.
            outline.page title: sub[:title], destination: sub[:page], closed: true
          end
        end
        # Dibuja la tabla solo con el titulo de oferta o demanda.
        table(title_content, column_widths: [title_width, page_width], position: :center, cell_style: {border_style: :none, borders: [], size: TEXT_CONFIG[:size], font_style: TEXT_CONFIG[:style], padding: [2,2,2,2]})
        # Dibuja la tabla con los contenidos.
        table(contents, column_widths: [title_width, page_width], position: :center, cell_style: {border_style: :none, borders: [], size: TEXT_CONFIG[:size], font_style: TEXT_CONFIG[:style]}) do
          style(columns(0), padding: [2,2,2,20])
          style(columns(1), padding: [2,2,2,2])
        end
      end

    end
  end

  def desercion_retencion(carrera)
    parts = []
    title = @num_title.to_s + ". " + carrera.nombre
    sub_title = @num_title.to_s + "." + @num_subtitle.to_s + " Deserción - Retención"

    data = []
    @total_estudiantes.each do |te|
      if carrera.id == te[:carrera]
        te[:anios].each do |te_anio|
          hash_data = {
            anio: te_anio[:anio],
            total: te_anio[:total],
            desertores: carrera.getEstudiantesDesertores(te_anio[:anio], true)
          }
          data << hash_data
        end
        break
      end
    end

    parts << {type: :title, content: title}
    parts << {type: :sub_title, content: sub_title}
    # space_points += getTotalHeight(parts)
    # checkPageSkip(space_points)

    # Dibujar titulo.
    drawTitle(title)

    # Dibujar subtitulo.
    drawSubTitle(sub_title)

    # Dibujar tabla.
    table_style = {position: :center, row_colors: ['d0d6dc', 'ffffff'], cell_style: {border_style: :none, :overflow => :shrink_to_fit, :min_font_size => 5}}

    # Header de la tabla.
    rows = [[make_cell(content: "Cohorte", align: :center, size: 9, font_style: :bold)]]
    @anios_ingreso.each do |anio|
      rows[0] << make_cell(content: "#{anio}", align: :center, size: 9, font_style: :bold, align: :center)
    end

    # Fila de % de desercion.
    rows_aux = [make_cell(content: "% Deserción", align: :center, size: 9, font_style: :bold)]
    data.each do |d|
      if d[:total] != 0
        desertores_perc = ((d[:desertores] * 100) / d[:total])
      else
        desertores_perc = 0
      end
      rows_aux << make_cell(content: "#{desertores_perc}%", size: 7, align: :center)
    end
    rows << rows_aux

    # Fila de % de retencion
    rows_aux = [make_cell(content: "% Retención", align: :center, size: 9, font_style: :bold)]
    data.each do |d|
      retencion_num = d[:total] - d[:desertores]
      if d[:total] != 0
        retencion_perc = ((retencion_num * 100) / d[:total])
      else
        retencion_perc = 0
      end
      rows_aux << make_cell(content: "#{retencion_perc}%", size: 7, align: :center)
    end
    rows << rows_aux

    # Fila de cantidad de desertores
    rows_aux = [make_cell(content: "Nº desertores", align: :center, size: 9, font_style: :bold)]
    data.each do |d|
      rows_aux << make_cell(content: "#{d[:desertores]}", size: 7, align: :center)
    end
    rows << rows_aux

    # Fila total cohorte
    rows_aux = [make_cell(content: "Total Cohorte", align: :center, size: 9, font_style: :bold)]
    data.each do |d|
      rows_aux << make_cell(content: "#{d[:total]}", size: 7, align: :center, font_style: :bold)
    end
    rows << rows_aux

    t = make_table(rows, table_style)
    pad(PADDING) do
      t.draw
    end

    # Sumar la altura del header.
    # space_points += t.row_heights.last

    # Grafico
    g = Gruff::Bar.new
    g.title = 'Desercion - Retencion'
    g.minimum_value = 0
    g.maximum_value = 100
    g.x_axis_label = 'Periodo académico'
    g.y_axis_label = '%'
    g.show_labels_for_bar_values = true
    g.label_formatting = "%.0f"
    labels = {}
    desercions = []
    reten = []
    data.each_with_index do |d, index|
      labels[index] = d[:anio].to_s
      if d[:total] != 0
        desertores_perc = ((d[:desertores] * 100) / d[:total])
      else
        desertores_perc = 0
      end

      if d[:total] != 0
        retencion_perc = (((d[:total] - d[:desertores]) * 100) / d[:total])
      else
        retencion_perc = 0
      end

      desercions << desertores_perc
      reten << retencion_perc
    end
    g.labels = labels
    g.data(:Desercion, desercions)
    g.data(:Retencion, reten)

    pad_bottom(PADDING * 2) do
      image StringIO.new(g.to_blob), GRAPH_POS
    end
  end

################################################################################
  # Oferta
  def oferta_modalidad(offer_title = nil, method_type = nil)
    sums, dist = @stats.offer_mode_dist(ANY_ROOMS, @type_of_property)
    sales_count = sums[0]
    rents_count = sums[1]
    total = sales_count + rents_count
    space_points = 0
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Modalidad"
    legend = ""
    parts = []

    if total != 0 # Si hay datos.
      legend = "De un total de " + total.to_s + " propiedades "\
        "publicadas en la"\
        " zona, " + sales_count.to_s + " estuvieron a la <b>venta</b> y " +
        rents_count.to_s + " estuvieron en <b>arriendo</b> durante el período analizado."
      # Sumar la altura del grafico.
      parts << {type: :graph}

    else # No hay datos.
      legend = NO_MESSAGE

    end

    # Sumar altura subtitulo
    parts << {type: :sub_title, content: title}
    # Sumar altura texto
    parts << {type: :text, content: legend}
    # Sumar altura de titulo oferta
    parts << {type: :offer_title, content: offer_title}

    space_points += getTotalHeight(parts)
    checkPageSkip(space_points)

    # Titulo oferta.
    drawOfferTitle(offer_title)

    # SubTitulo "Modalidad"
    drawSubTitle(title, :oferta)

    # Texto
    drawText(legend)

    # Dibujar el grafico solo cuando hayan datos de la BD.
    if total != 0
      g = Gruff::Pie.new
      g.theme = GRAPH_STYLE
      g.title = "Modalidad"
      g.data "Venta", [dist[0].to_i]
      g.data "Arriendo", [dist[1].to_i]
      pad_bottom(PADDING * 2) do
        image StringIO.new(g.to_blob), GRAPH_POS
      end      
    end
  end # END OFERTA_MODALIDAD

  def oferta_habitaciones(offer_title = nil, method_type = nil)
    # Consultas
    rooms_sums = @stats.offer_rooms_sums(ANY_MODE, @type_of_property)
    sales_dist = @stats.offer_rooms_dist(SALE, @type_of_property)
    rents_dist = @stats.offer_rooms_dist(RENT, @type_of_property)

    title = @num_title.to_s + "." + @num_subtitle.to_s + " Habitaciones"
    min_rooms = (@type_of_property == [HOUSE]) ? HOUSE_MIN_ROOMS : 1
    one_room_count = rooms_sums[0].to_s
    two_room_count = rooms_sums[1].to_s
    three_room_count = rooms_sums[2].to_s
    four_room_count = rooms_sums[3].to_s
    aux = (min_rooms + 3).to_s
    last_rooms_str = (min_rooms + 3 == MAX_ROOMS) ? (aux + "+") : aux
    space_points = 0
    legend = ""
    parts = []
    pass = false

    if rooms_sums[0] == 0 && rooms_sums[1] == 0 && rooms_sums[2] == 0 && rooms_sums[3] == 0
      # No hay datos
      legend = NO_MESSAGE

    else
      pass = true
      # Si hay datos
      legend = "La distribucion por <b>cantidad de habitaciones</b> muestra que"\
        " hubo " + one_room_count + " propiedades con #{min_rooms} "\
        "#{((min_rooms == 1) ? 'habitación' : 'habitaciones')}, " +
        two_room_count + " con #{(min_rooms + 1)} habitaciones, " +
        three_room_count + " con #{(min_rooms + 2)} habitaciones y " +
        four_room_count + " con #{last_rooms_str} habitaciones."

      # Ambos graficos.
      parts << {type: :graph, middle_graph: true}
      parts << {type: :graph}
    end

    # Titulo oferta, subtitulo y texto.
    parts << {type: :sub_title, content: title}
    parts << {type: :text, content: legend}
    parts << {type: :offer_title, content: offer_title}

    space_points += getTotalHeight(parts)
    checkPageSkip(space_points)

    # TITULO OFERTA
    drawOfferTitle(offer_title)

    # SUBTITULO
    drawSubTitle(title, :oferta)

    # TEXTO
    drawText(legend)

    if pass
      # GRAFICOS
      g = Gruff::Pie.new
      g.theme = GRAPH_STYLE
      g.title = "Venta"
      data_por_habitacion(sales_dist, g, OFFER)
      pad_bottom(PADDING) do
        image StringIO.new(g.to_blob), GRAPH_POS
      end

      g = Gruff::Pie.new
      g.theme = GRAPH_STYLE
      g.title = "Arriendo"
      data_por_habitacion(rents_dist, g, OFFER)
      pad_bottom(PADDING * 2) do
        image StringIO.new(g.to_blob), GRAPH_POS
      end
    end
  end # END OFERTA_HABITACIONES

  def promedio_area(offer_title = nil, method_type = nil)
    grafico_area_oferta(SALE, offer_title, true)
    offer_title = nil
    # Solo se obtendran los datos reales cuando sea grafico completo.
    grafico_area_oferta(RENT, offer_title, @complete_graph)
  end

  def promedio_metro_cuadrado(offer_title = nil, method_type = nil)
    grafico_ppm_oferta(SALE, offer_title, @complete_graph)
    offer_title = nil
    grafico_ppm_oferta(RENT, offer_title, @complete_graph)
  end

  def promedio_valor(offer_title = nil, method_type = nil)
    grafico_valor_oferta(SALE, offer_title, true)
    offer_title = nil
    grafico_valor_oferta(RENT, offer_title, @complete_graph)
  end

  def promedioPM2(offer_title = nil, method_type = nil)
    precioMetroM2PorHabitaciones('Venta', offer_title, @complete_graph)
    offer_title = nil
    precioMetroM2PorHabitaciones('Arriendo', offer_title, @complete_graph)
  end

  def precioMetroM2PorHabitaciones(mode, offer_title = nil, real_data = true)
    # Crear los meses del eje x del grafico.
    meses = MONTHS_AGO
    months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']
    labels = {}
    while meses != 0
      mon_index = (Date.today - meses.months).strftime("%m").to_i - 1
      labels[MONTHS_AGO - meses] =  months[mon_index] + "\n" + ((Date.today - meses.months).strftime("%Y").to_i).to_s
      meses -= 1
    end
    dates = []
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Precio promedio por m2 los últimos #{MONTHS_AGO} (#{mode})"
    legend = "Evolución del <b>valor promedio</b> en #{@currency_name} de las propiedades en"\
      " <b>#{mode}</b> en relación a la cantidad de habitaciones, durante los últimos #{MONTHS_AGO} meses."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if real_data
      pass = false
      # CONSULTAS BD
      @dates.split('-').each do |d|
        aux = d.split('/')
        dates.push(Time.new(aux[2], aux[1], aux[0]))
      end
      data = @stats.propertiesMeanPPR(MONTHS_AGO, mode, @currency_id, dates)

      if data[:hab1].size == 0 &&data[:hab2].size == 0 &&data[:hab3].size == 0 &&data[:hab4].size == 0 &&data[:hab5].size == 0
        # No hay datos
        legend = NO_MESSAGE

      else
        # Hay datos
        pass = true
        # Grafico
        parts << {type: :graph}
      end

      # Texto
      parts << {type: :text, content: legend}

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      # TEXTO
      drawText(legend)

      if pass
        # GRAFICO
        g = Gruff::Line.new
        g.theme = GRAPH_STYLE
        g.y_axis_label = "UF Unidad de Fomento"
        g.title = "Evolución precio promedio m2 en #{mode}"
        g.labels = labels
        g.baseline_value = 0
        g.baseline_color = 'transparent'

        g.data "1 hab", data[:hab1]
        g.data "2 hab", data[:hab2]
        g.data "3 hab", data[:hab3]
        g.data "4 hab", data[:hab4]
        g.data "+5 hab", data[:hab5]
        pad_bottom(PADDING * 2) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end
      end

    else
      # parts << {type: :text, content: legend}
      # space_points += getTotalHeight(parts)

      png_path = Rails.root.join('app', 'pdfs', 'placeholders', mode == 'Venta' ? 'precio_promediom2_venta_placeholder.jpg' : 'precio_promediom2_arriendo_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: 238})

    end
  end

  def decada_construccion(offer_title = nil, method_type = nil)

    title = @num_title.to_s + "." + @num_subtitle.to_s + " Antigüedad"
    legend = "<b>Década de construcción</b> de las propiedades "
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if @complete_graph
      pass = false
      # CONSULTAS BD
      years = [1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020]
      sales_data = @stats.offer_build_year_dist(
        SALE, ANY_ROOMS, @type_of_property, years
      )
      rents_data = @stats.offer_build_year_dist(
        RENT, ANY_ROOMS, @type_of_property, years
      )
      parenthesis = "<em>(sólo el " + ("%.2f" % sales_data[0]) + "% y el " +
        ("%.2f" % rents_data[0]) +
        "% de las propiedades para venta y arriendo respectívamente señalaron "\
        "el año de construcción).</em>"
      text_final = (legend + parenthesis)

      if sales_data[0].nan? && rents_data[0].nan?
        # No hay datos
        text_final = NO_MESSAGE

      else
        # Hay datos
        pass = true
        # Grafico
        parts << {type: :graph}
      end

      # Texto
      parts << {type: :text, content: legend}

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      # TEXTO
      drawText(text_final)

      if pass
        # GRAFICO
        g = Gruff::Line.new
        g.theme = GRAPH_STYLE
        g.title = "Antigüedad"
        g.y_axis_label = "Porcentaje del total (%)"
        g.labels = {
          0 => "1950",
          1 => "1960",
          2 => "1970",
          3 => "1980",
          4 => "1990",
          5 => "2000",
          6 => "2010",
          7 => "2020"
        }
        g.data "Venta", sales_data[1]
        g.data "Arriendo", rents_data[1]
        pad_bottom(PADDING * 2) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end
      end

    else
      # parts << {type: :text, content: legend}
      # space_points += getTotalHeight(parts)

      # ALTURA DE IMAGEN PLACEHOLDER
      fake_data_height = 230
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'antiguedad_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: fake_data_height})      
    end
  end

  def tasa_vacancia(offer_title = nil, method_type = nil)
    months = [3.months.ago.month, 2.months.ago.month, 1.months.ago.month]
    dates = []
    t = Time.now
    this_month = t.month
    this_year = t.year
    for m in months
      if this_month < m
        date = Date.new((this_year - 2), m)
      else
        date = Date.new(this_year - 1, m)
      end
      dates.push([date, date + 1.month])
    end
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Tasa de vacancia mensual"
    legend = "<b>Tasa de vacancia</b> de las propiedades ofrecidas para los úl"\
      "timos tres meses. " + [MESES[months[0]],  MESES[months[1]]].join(", ") + " y " +
      MESES[months[2]] + ".
      Esto se calcula a partir de las propiedades publicadas y dadas de baja mensualmente en razón de la cantidad de propiedades publicadas totales; otorgando un índice sobre la velocidad de vaciado del mercado en ese mes.
      "
    legend2 = "Nota: Si el índice es cercano a 100, quiere decir que el número de publicaciones es mucho mayor al número de publicaciones dadas de baja durante ese período."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      pass = false

      sales_data = @stats.offer_vacancy_dist(SALE, ANY_ROOMS, @type_of_property, dates)
      rents_data = @stats.offer_vacancy_dist(RENT, ANY_ROOMS, @type_of_property, dates)

      if sales_data.nil? &&rents_data.nil?
        # No hay datos
        legend = NO_MESSAGE
        parts << {type: :text, content: legend}

      else
        # Hay datos
        pass = true
        # Grafico
        parts << {type: :graph}
        # Ambos textos
        parts << {type: :text, content: legend, not_last: true}
        parts << {type: :text, content: legend2, indent: TEXT_INDENT + 20}
      end

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)
      
      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      if pass
        # Hay datos, mostrar textos y graficos.
        # 1er TEXTO
        drawText(legend, true)
        # 2ndo TEXTO
        drawText(legend2, false, TEXT_INDENT + 20)
        # GRAFICO
        grafico_vacancia(months, dates, sales_data, rents_data)
      
      else
        # Mensaje de error
        drawText(legend)
      end

      graficoPublishedTime()
    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 292
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'tasa_vacancia_mensual_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: fake_data_height})

    end
  end

  # HAY QUE VALIDAR SI ES GRAFICO COMPLETO O SIMPLE (@complete_graph)....
  def graficoPublishedTime()
    dates = formatDates()
    space_points = 0
    months_ago = 3
    legend = "Los siguientes gráficos dan cuenta de la velocidad con que las propiedades se venden o arriendan dado el comportamiento promedio en que éstas se publican y las mismas se dan de baja en la plataforma goplaceit.com durante los últimos #{months_ago} meses."
    labels = {0 => 'Casa', 1 => 'Departamento'}
    graph_width = 267 # Ancho de grafico calculado anteriormente.
    half = bounds.right / 2
    parts = []

    # CONSULTAS BD
    data = @stats.propertiesPublishedTime(months_ago, dates[:end_date])

    if data.nil?
      # No hay datos.
      legend = "No hay datos suficientes para la sección de <b>velocidad de venta y arriendo de propiedades.</b>"

    else
      # Hay datos.
      # ALTURA GRAFICOS (4)
      parts << {type: :graph, middle_graph: true}
      parts << {type: :graph}
    end

    # Calcular altura del texto con identacion.
    parts << {type: :text, content: legend}

    space_points += getTotalHeight(parts)
    checkPageSkip(space_points)

    # TEXTO
    drawText(legend)

    if !data.nil?
      # Hay datos.
      aux = 0
      # GRAFICO VENTA
      data[:venta].each do |type, rooms|
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Tiempo vigencia promedio en venta (#{type.to_s})"
        g.show_labels_for_bar_values = true
        g.title_font_size = 30
        g = formatDecimalLabels('venta', g)
        # g.x_axis_label = "Nº habitaciones"
        g.y_axis_label = 'Días'

        rooms.each do |hash_data|
          g.data(hash_data[0], hash_data[1])
        end
        g.minimum_value = 0

        if aux == 0
          float{image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half - graph_width}}
        else
          image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half}
        end
        aux += 1
      end
      aux = 0
      move_down PADDING

      # GRAFICO ARRIENDO
      data[:arriendo].each do |type, rooms|
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Tiempo vigencia promedio en arriendo (#{type.to_s})"
        g.title_font_size = 30
        g = formatDecimalLabels('arriendo', g)
        g.show_labels_for_bar_values = true
        # g.x_axis_label = "Nº habitaciones"
        g.y_axis_label = 'Días'

        rooms.each do |hash_data|
          g.data(hash_data[0], hash_data[1])
        end
        g.minimum_value = 0

        if aux == 0
          float{image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half - graph_width}}
        else
          image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half}
        end
        aux += 1
      end
      move_down PADDING * 2
    end # END data.nil?
  end # END graficoPublishedTime

  def propiedades_cercanas(offer_title = nil, method_type = nil)

    title = @num_title.to_s + "." + @num_subtitle.to_s + " Tabla de propiedades cercanas"
    legend = "En la siguiente tabla se muestran las 25 propiedades más cercanas - al punto central de la zona estudiada - publicadas en goplaceit.com además de otras fuentes de internet y vigentes durante los últimos #{monthsDifference} meses (#{@dates}). Este listado se construyó considerando sólo #{@types_names.upcase} ofertadas en el período señalado."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      # CONSULTAS BD
      data = @stats.closestPropertiesFromStatistic(@currency_id, @type_of_property, @modes)

      if !data.nil?
        # Hay datos.
        # Variable que controla si los titulos y textos de la seccion ya fueron dibujados
        # sirve para no volver a dibujarlos cuando se continua la tabla en la siguiente pagina. 
        table_header = false
        price_legend = @modes.is_a?(Array) ? true : false

        # TITULO OFERTA
        drawOfferTitle(offer_title)

        # ALTURA MARGENES DE TABLA
        space_points += PADDING * 2

        # Se suma por separado el texto por la identacion
        parts << {type: :text, content: legend, not_last: true}

        space_points += getTotalHeight(parts)

        table_style = {position: :center, row_colors: ['d0d6dc', 'ffffff'], cell_style: {border_style: :none, :overflow => :shrink_to_fit, :min_font_size => 5}, column_widths: {1 => 42, 4 => 42, 5 => 42, 6 => 54, 9 => 50}}
        # Armar la tabla (sin dibujar)
        rows = [[make_cell(content: "Nº", align: :center, size: 9, font_style: :bold), 
          make_cell(content: "Código GPI", align: :center, size: 9, font_style: :bold, align: :center),
          make_cell(content: "Código interno", align: :center, size: 9, font_style: :bold, align: :center), 
          make_cell(content: "Fuente", align: :center, size: 9, font_style: :bold, align: :center),
          make_cell(content: "Sup.\nÚtil (m<sup>2</sup>)", align: :center, size: 8, font_style: :bold, inline_format: true),
          make_cell(content: "Sup.\nTotal (m<sup>2</sup>)", align: :center, size: 8, font_style: :bold, inline_format: true),
          make_cell(content: "Tipo Propiedad", align: :center, size: 8, font_style: :bold, inline_format: true),
          make_cell(content: "Precio (#{@currency_prefix})", align: :center, size: 9, font_style: :bold, align: :center),
          make_cell(content: "Ubicación", align: :center, size: 9, font_style: :bold),
          make_cell(content: "Distancia (m)", align: :center, size: 9, font_style: :bold, align: :center)]]

        t = make_table(rows, table_style)
        space_points += t.row_heights.last

        num = 1
        data.each do |key, value|
          codigo_interno = key.id_portal.to_s
          # gpi_link = "http://www.goplaceit.com/cl/propiedad/#{key.id.to_s}"
          codigo_interno += " (<link href='http://www.goplaceit.com/cl/propiedad/#{key.id.to_s}'><i><u>link</u></i></link>)" if key.fuente == 'Goplaceit'

          precision = key.modalidad == "A" ? 2 : 1
          precio_temp = formatNumberCurrency(key.precio, precision)
          precio_cell = price_legend ? precio_temp + " (#{key.modalidad.to_s})" : precio_temp
          row_aux = [make_cell(content: num.to_s, size: 7, align: :center),
            make_cell(content: key.id.to_s, size: 7, align: :center), 
            make_cell(content: codigo_interno, size: 7, inline_format: true, align: :center),
            make_cell(content: key.fuente, size: 6, min_font_size: 5, overflow: :shrink_to_fit, align: :center),
            make_cell(content: key.dimension_propiedad.to_i.to_s, size: 7, align: :center), 
            make_cell(content: key.dimension_terreno.to_i.to_s, size: 7, align: :center), 
            make_cell(content: key.tipo_propiedad.nombre, size: 7, align: :center), 
            make_cell(content: precio_cell, size: 7, align: :center), 
            make_cell(content: key.direccion, size: 6), 
            make_cell(content: key.distancia.to_f.to_s, size: 7, align: :center)]
          rows.push(row_aux)

          # Se crea la tabla con las filas creadas hasta el momento para poder asi
          # calcular la altura actual de la tabla y poder revisar si hacer salto de pagina.
          t = make_table(rows, table_style)
          # Se suma la altura de la ultima celda de la tabla.
          space_points += t.row_heights.last

          # Si la tabla ya excede la pagina.
          if checkPageSkip(space_points, true)
            # Se saca la ultima fila de la tabla y para incluirla en la siguiente pagina
            # junto con el header de la tabla
            last_row = rows.last
            # Se guardan todas las filas excepto la ultima para que al dibujar la tabla
            # no pase a la siguiente pagina
            rows = rows.first(rows.size - 1)
            # Si hay mas de una fila a dibujar se dibuja la tabla en la pagina actual
            # y sigue en la siguiente dejando tomando el alto de la cabecera de la tabla
            # en la variable space_points.
            if rows.size > 1
              if !table_header
                table_header = true
                # TITULO
                drawSubTitle(title, :oferta)
                # TEXTO
                drawText(legend, true)
              end

              # TABLA
              t = make_table(rows, table_style)
              pad(PADDING) do
                t.draw
              end
              
              # Hacer el salto de pagina + dibujar header y continuar dibujando la tabla.
              checkPageSkip(space_points)
              rows = [rows[0], last_row]
              space_points = make_table(rows, table_style).height + PADDING * 2
            else
              rows << last_row
              # Si solo esta la cabecera y hay salto de pagina, se sigue armando la tabla sin dibujarlo.
              # Hacer el salto de pagina + dibujar header y continuar dibujando la tabla.
              checkPageSkip(space_points)
              if !table_header
                table_header = true
                # TITULO
                drawSubTitle(title, :oferta)
                # TEXTO
                drawText(legend, true)
              end
            end # END ROWS.SIZE > 1
          end # END CHECKPAGESKIP
          num += 1
        end

        if !table_header
          # TITULO
          drawSubTitle(title, :oferta)
          # TEXTO
          drawText(legend, true)
        end

        # TABLA
        t = make_table(rows, table_style)
        pad(PADDING) do
          t.draw
        end

        # Diubjar leyenda de modalidad, 
        # SOLO CUANDO SE ELIGE MODALIDAD = 'CUALQUIERA'
        if price_legend
          legend_title = "Leyenda:"
          space_points = height_of(legend_title, {inline_format: true, align: TEXT_CONFIG[:align], size: TEXT_CONFIG[:size], style: :bold})
          legends = "* 'A' : Arriendo\n* 'V' : Venta"

          indent TEXT_INDENT * 2 do
            space_points += height_of(legends, TEXT_CONFIG) + PADDING
          end
          checkPageSkip(space_points)

          text legend_title, {inline_format: true, align: TEXT_CONFIG[:align], size: TEXT_CONFIG[:size], style: :bold}

          drawText(legends, false, TEXT_INDENT * 2)
        end

      else
        # No hay datos.
        legend = NO_MESSAGE
        parts << {type: :text, content: legend}

        space_points += getTotalHeight(parts)
        checkPageSkip(space_points)

        # TITULO OFERTA
        drawOfferTitle(offer_title)

        # TITULO
        drawSubTitle(title, :oferta)

        # TEXTO
        drawText(legend)
      end # END data.nil?

    else # SOLO PARA GRAFICO BASICO
       fake_data_height = 312
       space_points += fake_data_height
       png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'propiedades_cercanas_placeholder.jpg')
       drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: fake_data_height, position: GRAPH_POS[:position], indent: 0})

    end # END @complete_graph 
  end

  def grafico(offer_title = nil, method_type = nil)
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Tabla de promedio de propiedades"
    space_points = 0
    parts = []

    # ALTURA TITULO OFERTA 
    parts << {type: :offer_title, content: offer_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      # CONSULTAS BD
      data = @stats.graficox(@currency_id, @type_of_property, @modes)
      # ESTO ES SOLO PARA PRUEBAS
      # data = {data: {:venta=>{:util=>{:"200"=>99, :"500"=>99, :"1000"=>99, :"1500"=>99, :id_comuna=>99, :id_barrio=>"-"}, :total=>{:"200"=>99, :"500"=>99, :"1000"=>99, :"1500"=>99, :id_comuna=>99, :id_barrio=>"-"}}, :arriendo=>{:util=>{:"200"=>99, :"500"=>99, :"1000"=>99, :"1500"=>99, :id_comuna=>99, :id_barrio=>"-"}, :total=>{:"200"=>99, :"500"=>99, :"1000"=>99, :"1500"=>99, :id_comuna=>99, :id_barrio=>"-"}}},locations: {comuna: 'comuna de prueba', neighborhood: 'barrio de prueba'}}

      # Revisar si existen datos de la BD.
      if !data[:data].nil?
        months = monthsDifference

        legend = "En la siguiente tabla se muestran promedios de precios en UF/m2 de las propiedades publicadas en goplaceit.com además de otras fuentes de internet,  y vigentes durante los últimos #{months} meses (#{@dates}). Este promedio de precios se construyó considerando sólo #{@types_names.upcase} ofertadas en el período señalado.

          Se hace distinción en dos modalidades calculadas, utilizando la superficie útil (o superficie construida) informada: “Útil”, y la superficie total informada: “Total”. Además de valores promedio para propiedades a los 200 metros a la redonda desde el punto central del área analizada, luego 200, 500, 1000 y 1500 metros a la redonda. También se muestran los valores promedio de la comuna '#{data[:locations][:comuna]}' y el barrio '#{data[:locations][:neighborhood]}' al cual pertenece la zona estudiada.
          "

        parts << {type: :text, content: legend, not_last: true}

        # Armar la tabla (sin dibujar)
        table_options = {width: bounds.width, row_colors: ['d0d6dc', 'ffffff'], cell_style: {border_style: :none, :overflow => :shrink_to_fit, :min_font_size => 6}}
        header_options = {align: :center, size: 9, font_style: :bold}
        # Se guarda en un array el titulo de la tabla y la tabla para ayudar el calculo de altura y su dibujado
        tables = []

        data[:data].each do |k,v|
          precision = k == :arriendo ? 2 : 1
          table_title = k.to_s.capitalize + " (#{@currency_name})"
          space_points += height_of(table_title, TEXT_SUBTITLE_CONFIG) + PADDING * 2

          # Verificar si la modalidad (venta - arriendo) tiene datos.
          if !v.nil?
            rows = [[
              make_cell(content: 'Modalidad', align: :center, size: 9, font_style: :bold),
              make_cell(content: '200m', align: :center, size: 9, font_style: :bold),
              make_cell(content: '500m', align: :center, size: 9, font_style: :bold),
              make_cell(content: '1000m', align: :center, size: 9, font_style: :bold),
              make_cell(content: '1500m', align: :center, size: 9, font_style: :bold),
              make_cell(content: 'Comuna', align: :center, size: 9, font_style: :bold),
              make_cell(content: 'Barrio', align: :center, size: 9, font_style: :bold),
              ]]

            v.each do |k2, v2|
              aux = [
                make_cell(content: k2.to_s.capitalize, size: 8, align: :center),
                make_cell(content: formatNumberCurrency(v2[:"200"], precision), size: 8),
                make_cell(content: formatNumberCurrency(v2[:"500"], precision), size: 8),
                make_cell(content: formatNumberCurrency(v2[:"1000"], precision), size: 8),
                make_cell(content: formatNumberCurrency(v2[:"1500"], precision), size: 8),
                make_cell(content: formatNumberCurrency(v2[:id_comuna], precision), size: 8),
                make_cell(content: formatNumberCurrency(v2[:id_barrio], precision), size: 8),
              ]
              rows.push(aux)
            end

            t = make_table(rows, table_options)
            space_points += t.height + PADDING
            # Se guarda el titulo de la tabla y su tabla.
            tables << {title: table_title, table: t}

          else 
            # Si no hay datos suficientes para la modalidad, se pone un mensaje.
            error_msg = "No hay información suficiente."
            parts << {type: :text, content: error_msg, not_last: true}
            tables << {title: table_title, error: error_msg}
          end # END v.nil?
        end # END data.each

        space_points += getTotalHeight(parts)
        checkPageSkip(space_points)

        # TITULO OFERTA
        drawOfferTitle(offer_title)
        
        # TITULO
        drawSubTitle(title, :oferta)

        # TEXTO
        drawText(legend, true)

        # DIBUJAR TITULO DE LA TABLA Y SU TABLA
        tables.each do |k|
          drawSubTitle(k[:title], :oferta, false, false)

          if k[:error]
            indent TEXT_INDENT do
              text k[:error], TEXT_CONFIG
            end
          else
            pad_bottom(PADDING) do
              k[:table].draw
            end
          end # END k[:error]
        end # END tables.each
        
      else # Si de la BD no se encontraron datos, se coloca un mensaje de alerta.
        legend = NO_MESSAGE
        parts << {type: :text, content: legend}

        space_points += getTotalHeight(parts)
        checkPageSkip(space_points)

        # TITULO OFERTA
        drawOfferTitle(offer_title)

        # TITULO
        drawSubTitle(title, :oferta)

        # TEXTO
        drawText(legend)
      end # END data[:data].nil?
      
    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 353
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'promedio_propiedades_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: fake_data_height, position: GRAPH_POS[:position], indent: 0})

    end
  end

  ##############################################################################
  # Demanda
  def distribucion_genero(demand_title = nil, method_type = nil)
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Por género"
    space_points = 0
    parts = []

    # ALTURA TITULO DEMANDA
    parts << {type: :offer_title, content: demand_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      # CONSULTAS BD
      useful_users = @stats.users_filter(ANY_MODE, ANY_ROOMS, @type_of_property).where{
        (fecha_nacimiento != nil) & (id_genero != nil)
      }
      users_count = @stats.users_filter(ANY_MODE, ANY_ROOMS, @type_of_property).count
      data = {venta: @stats.demand_gender_dist(1, ANY_ROOMS, @type_of_property), arriendo: @stats.demand_gender_dist(2, ANY_ROOMS, @type_of_property)}
      pass = false

      if useful_users.present? && users_count != 0 && !(data[:venta].nil? && data[:arriendo].nil?)
        # Hay datos.
        pass = true
        perc = users_count != 0 ? (useful_users.count.to_f / users_count * 100) : 0
        legend = "<b>" + users_count.to_s + " personas</b> buscaron "\
          "propiedades en la zona de estadística. De éstas sólo el " + "%d" % perc +
          "% entregó información de género y edad."
        # ALTURA GRAFICO
        parts << {type: :graph}

      else
        # No hay datos.
        legend = NO_MESSAGE
      end

      # ALTURA TEXTO
      parts << {type: :text, content: legend}

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)
      
      # TITULO
      drawSubTitle(title, :demanda)

      # TEXTO
      drawText(legend)

      if pass
        graph_width = 270 # Ancho de grafico calculado anteriormente.
        half = bounds.right / 2

        # GRAFICO VENTA
        g = Gruff::Pie.new
        g.theme = GRAPH_STYLE
        g.title = "Género (Venta)"
        g.data("Masculino", data[:venta][0])
        g.data("Femenino", data[:venta][1])
        float{image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half - graph_width}}

        # GRAFICO ARRIENDO
        g = Gruff::Pie.new
        g.theme = GRAPH_STYLE
        g.title = "Género (Arriendo)"
        g.data("Masculino", data[:arriendo][0])
        g.data("Femenino", data[:arriendo][1])
        image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half}

        move_down PADDING * 2
      end # END pass

    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 232
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'por_genero_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height})
    end
  end

  def distribucion_edad(demand_title = nil, method_type = nil)
    ages = [18, 25, 30, 38, 50, 65, 80]
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Por distribución por edad"
    space_points = 0
    parts = []
    legend = ""

    # ALTURA TIUTLO DEMANDA
    parts << {type: :offer_title, content: demand_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      pass = false
      # CONSULTAS BD
      dist = {venta: @stats.demand_age_dist(1, ANY_ROOMS, @type_of_property, ages), arriendo: @stats.demand_age_dist(2, ANY_ROOMS, @type_of_property, ages)}

      if !(dist[:venta].nil? && dist[:arriendo].nil?)
        # Hay datos.
        pass = true
        # ALTURA GRAFICO
        parts << {type: :graph}

      else
        # No hay datos.
        legend = NO_MESSAGE
        parts << {type: :text, content: legend}
      end

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)

      # TITULO
      drawSubTitle(title, :demanda)

      if pass
        graph_width = 267 # Ancho de grafico calculado anteriormente.
        half = bounds.right / 2

        # GRAFICO VENTA
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Distribución por edad (Venta)"
        g.labels = {
          0 => "18-24",
          1 => "25-29",
          2 => "30-37",
          3 => "38-49",
          4 => "50-64",
          5 => "65-80"
        }
        g.x_axis_label = "Rango de edad"
        g.y_axis_label = "Personas (%)"
        g = formatDecimalLabels('venta', g)
        g.data(:Edad, dist[:venta])
        g.show_labels_for_bar_values = true
        g.minimum_value = 0
        float{image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half - graph_width}}

        # GRAFICO VENTA
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Distribución por edad (Arriendo)"
        g.labels = {
          0 => "18-24",
          1 => "25-29",
          2 => "30-37",
          3 => "38-49",
          4 => "50-64",
          5 => "65-80"
        }
        g.x_axis_label = "Rango de edad"
        g.y_axis_label = "Personas (%)"
        g.data(:Edad, dist[:arriendo])
        g = formatDecimalLabels('arriendo', g)
        g.show_labels_for_bar_values = true
        g.minimum_value = 0
        image StringIO.new(g.to_blob), {height: GRAPH_POS[:height], position: half}

        move_down PADDING * 2
      else
        # TEXTO
        drawText(legend)
      end # END pass

    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 185
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'distribucion_de_edad_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height, position: GRAPH_POS[:position]})
    end
  end # END distribucion_edad

  def demanda_habitaciones(demand_title = nil, method_type = nil)
    demanda_habitacion(SALE, demand_title, method_type)
    demand_title = nil
    demanda_habitacion(RENT, demand_title, method_type)
  end

  def demanda_habitacion(mode, demand_title = nil, method_type = nil)
    mode_text = mode == SALE ? 'venta' : 'arriendo'
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Por cantidad de habitaciones (#{mode_text})"
    space_points = 0
    indent2 = TEXT_INDENT + 40
    parts = []

    # ALTURA TIUTLO DEMANDA
    parts << {type: :offer_title, content: demand_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      pass = false
      # CONSULTAS BD
      rooms_sums = []
      sums, dist = @stats.demand_rooms_dist(mode, @type_of_property)
      nil_rooms = @stats.zones_count(mode, nil, @type_of_property)

      if !(sums.nil? && dist.nil?)
        # Hay datos
        pass = true
        legend = "De las <b>" + @zones_count.to_s + "</b> zonas creadas durante el periodo analizado:"
        legend2 = ""
        legend3 = "- Y " + nil_rooms.to_s + " zonas no especifican número de habitaciones."
        for rooms in 1..4
          legend2 += "- " + ((dist[rooms - 1].round).to_s + "% buscaban propiedades de <b>" + rooms.to_s + " o más </b> habitaciones.\n")
        end

        # ALTURA TEXTO EN FORMA DE LISTA
        parts << {type: :text, content: legend, padding: 10}
        parts << {type: :text, content: legend2, indent: indent2, not_last: true}
        parts << {type: :text, content: legend3, indent: indent2}
        # ALTURA GRAFICO
        parts << {type: :graph}

      else
        # No hay datos
        legend = NO_MESSAGE
        # ALTURA TEXTO
        parts << {type: :text, content: legend}
      end

      # ALTURA TEXTO
      # indent TEXT_INDENT do
      #   space_points += (height_of(legend, TEXT_CONFIG) + 10)
      # end

      # indent indent2 do
      #   space_points += height_of(legend2, TEXT_CONFIG)
      #   space_points += height_of(legend3, TEXT_CONFIG) + PADDING
      # end

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)

      # TITULO
      drawSubTitle(title, :demanda)

      if pass
        # TEXTO
        drawText(legend, false, TEXT_INDENT, 10)
        # indent TEXT_INDENT do
        #   text legend, TEXT_CONFIG
        # end
        # move_down 10

        # TEXTO
        drawText(legend2, true, TEXT_INDENT + 40)
        # indent (TEXT_INDENT + 40) do
        #   text legend2, TEXT_CONFIG
        # end

        # TEXTO
        drawText(legend3, false, TEXT_INDENT + 40)
        # pad_bottom(PADDING) do
        #   indent (TEXT_INDENT + 40) do
        #     text legend3, TEXT_CONFIG
        #   end
        # end

        # GRAFICO
        g = Gruff::Pie.new
        g.theme = GRAPH_STYLE
        g.title = "Demanda por cantidad de habitaciones (#{mode_text})"
        g.title_font_size = 30
        data_por_habitacion(dist, g, DEMAND)
        pad_bottom(PADDING * 2) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end
      else
        # TEXTO sin datos.
        drawText(legend)
      end # END pass

    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 295
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'cantidad_de_habitaciones_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height})
    end
  end

  def demanda_modalidad(demand_title = nil, method_type = nil)
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Por modalidad"
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: demand_title}
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      pass = false
      # CONSULTAS BD
      sums, dist = @stats.demand_mode_dist(ANY_ROOMS, @type_of_property)

      if sums.nil? || dist.nil?
        # No hay datos.
        legend = NO_MESSAGE
        
      else
        # Hay datos.
        pass = true
        sales_count = sums[SALE]
        rents_count = sums[RENT]
        dont_care_count = sums[DONT_CARE]
        legend = "Hay " + sales_count.to_s + " zonas que buscaron <b>venta</b>"\
          ", " + rents_count.to_s + " <b>arriendo</b> y " +
          dont_care_count.to_s + " eran indiferentes a comprar o arrendar."
        # ALTURA GRAFICO
        parts << {type: :graph}
      end      

      # ALTURA TEXTO
      parts << {type: :text, content: legend}

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)

      # TITULO
      drawSubTitle(title, :demanda)

      # TEXTO
      drawText(legend)

      if pass
        # GRAFICO
        g = Gruff::Pie.new
        g.theme = GRAPH_STYLE
        g.title = "Demanda por modalidad"
        g.data("Venta", [dist[SALE]])
        g.data("Arriendo", [dist[RENT]])
        g.data("indiferente", [dist[DONT_CARE]])
        pad_bottom(PADDING * 2) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end
      end

    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 205
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'por_modalidad_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height})

    end
  end # END demanda_modalidad

  def min_area(demand_title = nil, method_type = nil)
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Por disposición mínima de superficie"
    legend = "Valor promedio para la mínima superficie buscada para cada tipo de inmueble en las diferentes modalidades <b>venta</b> y "\
      "<b>arriendo</b>."
    space_points = 0
    parts = []

    # ALTURA TITULO DEMANDA
    parts << {type: :offer_title, content: demand_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      pass = false
      # CONSULTAS BD
      sales_data = getZonesMeanAreaData(SALE)
      rent_data = getZonesMeanAreaData(RENT)

      if sales_data.nil? || rent_data.nil?
        # No hay datos.
        legend = NO_MESSAGE

      else
        # Hay datos.
        pass = true
        # ALTURA 2 GRAFICOS
        parts << {type: :graph, middle_graph: true}
        parts << {type: :graph}
      end

      # ALTURA TEXTO
      parts << {type: :text, content: legend}

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)

      # TITULO
      drawSubTitle(title, :demanda)

      # TEXTO
      drawText(legend)

      if pass
        # GRAFICO
        grafico_area_demanda(SALE, sales_data)
        move_down PADDING

        grafico_area_demanda(RENT, rent_data)
        move_down PADDING * 2
      end
      
    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 438
      space_points += fake_data_height
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'por_disposicion_minima_sup_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height})
    end
  end

  def max_precios(demand_title = nil, method_type)
    max_precios_por_modalidad(SALE, demand_title)
    demand_title = nil
    max_precios_por_modalidad(RENT, demand_title)
  end

  ##############################################################################
  #########################     Funciones Secundarias     ######################
  ##############################################################################

  private
    # Funcion que verifica si el contenido a dibujar en el pdf (texto, graficos, etc)
    # ocupara dentro de la pagina actual. Recibe como parametro la altura de todos los elementos a dibujar (pdf_points)
    # y se resta con la posicion del cursor del pdf.
    def checkPageSkip(pdf_points, only_check = false)
      # Si el contenido a dibujar sobrepasa la pagina actual, se hace un salto de pagina y dibuja el header.
      if cursor - pdf_points < 0
        if !only_check
          start_new_page
          drawHeader
        end
        return true
      else
        return false
      end
    end

    def singularPluralStr(rooms)
      return rooms > 1 ? "habitaciones" : "habitación"
    end

    # Funcion que varia la cantidad de decimales en los valores mostrados de los graficos de GRUFF,
    # dependiendo de la modalidad (venta y arriendo).
    def formatDecimalLabels(modalidad, gruff)
      if modalidad =~ /venta/i || modalidad == 1
        gruff.label_formatting = "%.1f"

      elsif modalidad =~ /arriendo/i || modalidad == 2
        gruff.label_formatting = "%.2f"
      
      end
      return gruff
    end

    def formatNumberCurrency(number, precision = 2)
      return number_to_currency(number, precision: precision,  separator: ",", delimiter: ".", unit: '').strip
    end

    # Funcion que verifica los errores cuando los datos son calculados. 
    # Recibe como parametro los errores como string.
    def printErrors(errors)
      # Si existen errores que mostrar, se verifica su altura y luego se muestra los errores.
      if !errors.nil?
        error_space_points = 0
        indent TEXT_INDENT do
          error_space_points += height_of(errors, TEXT_CONFIG) + PADDING
          checkPageSkip(error_space_points)
          # TEXTO ERROR
          pad(PADDING) do
            text errors, TEXT_CONFIG
          end
        end
      end
    end

    # Dibuja el mapa de la zona creada en el pdf.
    def mapImage
      points = [] # Array de puntos (lat, lng) del poligono
      tolerance = 0.0003  # Tolerancia para la simplicacion de poligonos.

      if @stats.type_of_overlay_id == 1
        geo = RGeo::Cartesian::Factory.new(srid: 4326).parse_wkt(@stats.overlay)
      elsif @stats.type_of_overlay_id == 2
        geo = RGeo::Geographic.spherical_factory(srid: 4326, buffer_resolution: 8).point(@stats.lon, @stats.lat).buffer(@stats.radius)
      end
      exterior_rings = geo.exterior_ring.points

      # Simplificar el poligono para evitar problemas con los mapas estaticos,
      # solo se pueden enviar hasta 100 puntos
      while exterior_rings.size >= 100 && tolerance < 1
        # puts "TOLERANCE: #{tolerance}".green
        f = RGeo::Geos.factory(srid: 4326)
        poly = f.polygon(geo.exterior_ring).fg_geom.simplify(tolerance)
        sim_poly = f.wrap_fg_geom(poly) 
        exterior_rings = sim_poly.exterior_ring.points
        tolerance += 0.0001
      end

      exterior_rings.each do |p|
        points.push([p.x, p.y])
      end

      url = URI.parse("http://static-maps.yandex.ru/1.x/?lang=en-US&l=map&pl=c:FF0000A0,f:FF000034,w:6,#{points.join(',')}")
      pass = false
      tries = 1

      while !pass && tries <= 5
        open(url.to_s) do |http|
          if http.status[0] == '200'
            image StringIO.new(http.read), GRAPH_POS
            pass = true
          end
          tries += 1
        end
      end

      # Se intentara descargar el mapa estatico hasta 5 veces en caso de error.
    end

    # Devuelve la diferencia de meses entre las fechas de vigencia de propieades entregada.
    def monthsDifference
      dates = formatDates
      ((dates[:start_date] - dates[:end_date]).to_i / 30).to_i
    end

    # Devuelve las fechas de vigencia de las propiedades como objetos de fecha.
    def formatDates
      dates = @dates.split('-')
      return {start_date: Date.parse(dates[0]), end_date: Date.parse(dates[1])}
    end

    def drawFakeData(space_points, png_path, title, type, offer_title, graph_options = {})
      # SOLO CONTAR EL ESPACIO DEL IMAGEN
      checkPageSkip(space_points)

      # TITULO OFERTA / DEMANDA
      if offer_title.present?
        if type == :oferta
          drawOfferTitle(offer_title)
        else
          drawDemandTitle(offer_title)
        end
      end

      # TITULO
      if title.present?
        drawSubTitle(title, type, true, true, true)
      end

      height = graph_options[:height] ? graph_options[:height] : GRAPH_POS[:height]
      position = graph_options[:position] ? graph_options[:position] : :left
      padding = graph_options[:padding] ? graph_options[:padding] : PADDING * 2
      indent_amount = graph_options[:indent] ? graph_options[:indent] : TEXT_INDENT

      # IMAGEN PLACEHOLDER
      indent indent_amount do
        pad_bottom(padding) do
          image png_path, {height: height, position: position}
        end
      end
    end

    def removeTildes(str)
      tildes = {'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u', 'Á' => 'a', 'É' => 'e', 'Í' => 'i', 'Ó' => 'o', 'Ú' => 'u'}
      str = str.gsub(/[áéíóúÁÉÍÓÚ]/, tildes)
      str
    end

    def drawTitle(title)
      if !title.nil?
        drawHeader
        # Titulo formateado, ayuda para los vinculos del indice.
        format_offer_title = removeTildes(title.downcase)
        add_dest format_offer_title, dest_xyz(bounds.absolute_left, y)
        # OFERTA TITULO
        pad(PADDING) do
          text title, TEXT_TITLE_CONFIG
        end
        # @index[:oferta][:page] = page_number
        # @index[:oferta][:title] = title
        # @index[:oferta][:format_title] = format_offer_title
      end
    end

    # Dibujar los subtitulos de los distintos graficos.
    def drawSubTitle(sub_title, not_sub = true, to_index = true, fake = false)
      # Agregar punto de destino a este modulo para los enlaces del indice.
      add_dest removeTildes(sub_title.downcase), dest_xyz(bounds.absolute_left, y)
      # Agregar la seccion al array para usarlo en el indice.
      # addContentToIndex(sub_title, mode, fake) if to_index
      # Dibujar el subtitulo.
      pad(PADDING) do
        text sub_title, TEXT_SUBTITLE_CONFIG
      end
      @num_subtitle += 1 if not_sub
    end

    def drawText(legend, no_padding = false, indent_amount = TEXT_INDENT, padding = PADDING)
      if no_padding
        indent indent_amount do
          text legend, TEXT_CONFIG
        end

      else
        pad_bottom(padding) do
          indent indent_amount do
            text legend, TEXT_CONFIG
          end 
        end 
      end
    end # END drawText

    def getTotalHeight(parts)
      space_points = 0

      # Se calcula la altura para...
      parts.each do |part|
        case part[:type]
          # Subtitulos
          when :sub_title
            space_points += height_of(part[:content], TEXT_SUBTITLE_CONFIG) + PADDING * 2
            
          # Textos (con identacion)
          when :text
            indent_amount = part[:indent].nil? ? TEXT_INDENT : part[:indent]
            # puts "text indent_amount: #{indent_amount}".purple

            indent indent_amount do 
              space_points += height_of(part[:content], TEXT_CONFIG)

              if !part[:padding].nil?
                # Si el texto tiene un padding distinto.
                space_points += part[:padding]

              else
                # Se usa el padding por defecto, solo si el texto no es unico en la seccion (part[:not_last])
                space_points += PADDING if part[:not_last].nil?
              end
            end # END indent

          # Graficos (ultimos y no ultimos)
          when :graph
            if !part[:middle_graph].nil?
              # puts "GRAPH".purple
              space_points += GRAPH_POS[:height] + PADDING
            else
              # puts "LAST GRAPH".purple
              space_points += GRAPH_POS[:height] + PADDING * 2
            end

          # Titulo (Oferta o Demanda)
          when :title
            if !part[:content].nil?
              # puts "OFFER TITLE HEIGHT".purple
              space_points += height_of(part[:content], TEXT_TITLE_CONFIG) + PADDING * 2

            else
              # puts "NO OFFER TITLE HEIGHT".purple
              
            end
            
          else
          
        end
      end # END PARTS.EACH

      return space_points
    end

    def getOfferTitleHeight(offer_title)
      return height_of(offer_title, TEXT_TITLE_CONFIG) + PADDING * 2
    end

    # Dibuja la marca de agua, como header que va al principio de cada hoja.
    def drawHeader
      if cursor == bounds.top
        bounding_box([bounds.left, bounds.top], width: bounds.right, height: 30) do
          transparent(0.5) do 
            float{image "#{Rails.root}/app/assets/images/central.png", height: 30, position: :left, vposition: :center}
            text "#{Time.new.strftime('%d-%m-%Y')}", align: :right, valign: :center
          end
        end
      end
    end

    def addContentToIndex(title, section, fake)
      @index[section][:sections].push({title: title, format_title: removeTildes(title.downcase), section: @num_title.to_s, sub_section: @num_subtitle.to_s, page: page_number, fake: fake})
    end

    def getZonesMeanAreaData(modalidad)
      rooms_sums = [[:inferior, []], [:normal, []], [:superior, []]]
      zero_count = 0
      room_limit = 4

      for rooms in 1..room_limit
        room_data = @stats.zones_mean_area(modalidad, rooms, @type_of_property)
        zero_count += 1 if (room_data[:inferior] == 0 && room_data[:normal] == 0 && room_data[:superior] == 0)
        rooms_sums[0][1] << room_data[:inferior]
        rooms_sums[1][1] << room_data[:normal]
        rooms_sums[2][1] << room_data[:superior]
      end

      return zero_count == room_limit ? nil : rooms_sums
    end # END getZonesMeanAreaData


  def max_precios_por_modalidad(modalidad, demand_title = nil)
    max_precios_promedio(modalidad, demand_title)
    demand_title = nil
    parts = []
    space_points = 0

    if modalidad == SALE
      aux = "Venta"
      precios = [2000, 4000, 6000]
    else
      aux = "Arriendo"
      precios = [200000, 400000, 600000, 800000, 1000000, 1200000]
    end

    legend = "Demanda para <b>#{aux}</b> por habitación por rango de precios."

    # ALTURA TEXTO
    parts << {type: :text, content: legend}
    # indent TEXT_INDENT do
    #   space_points += height_of(legend, TEXT_CONFIG) + PADDING
    # end

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      # ALTURA GRAFICO
      # parts << {type: :graph, middle_graph: true}
      # space_points += GRAPH_POS[:height] + PADDING

      # Solo se verificara el espacio del titulo y el primer grafico,
      # luego se verifica el espacio por cada siguiente grafico.
      # space_points += getTotalHeight(parts)
      # checkPageSkip(space_points)

      # TEXTO
      # drawText(legend)
      # pad_bottom(PADDING) do 
      #   indent TEXT_INDENT do
      #     text legend, TEXT_CONFIG
      #   end
      # end

      # GRAFICOS
      max_precio_rango(modalidad, 1, precios, parts, legend)
      # move_down PADDING

      # space_points = (GRAPH_POS[:height] + PADDING)
      # checkPageSkip(space_points)

      aumentar_precio(modalidad, precios, 2)
      max_precio_rango(modalidad, 2, precios)
      # move_down PADDING

      # space_points = (GRAPH_POS[:height] + PADDING)
      # checkPageSkip(space_points)

      aumentar_precio(modalidad, precios, 3)
      max_precio_rango(modalidad, 3, precios)
      # move_down PADDING

      # space_points = (GRAPH_POS[:height] + PADDING * 2)
      # checkPageSkip(space_points)

      aumentar_precio(modalidad, precios, 4)
      max_precio_rango(modalidad, 4, precios, [], "", true)
      # move_down PADDING * 2

    else # SOLO PARA GRAFICO BASICO
      # TEXTO
      pad_bottom(PADDING) do 
        indent TEXT_INDENT do
          text legend, TEXT_CONFIG
        end
      end
      # 1 HABITACION
      fake_data_height = 178
      space_points += fake_data_height + PADDING
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'disposicion_a_pagar_venta2_placeholder.jpg' : 'disposicion_a_pagar_arriendo2_placeholder.jpg')
      drawFakeData(space_points, png_path, nil, :demanda, demand_title, {height: fake_data_height, padding: PADDING, position: GRAPH_POS[:position]})

      # 2 HABITACIONES
      fake_data_height = 178
      space_points = fake_data_height + PADDING * 2
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'disposicion_a_pagar_venta3_placeholder.jpg' : 'disposicion_a_pagar_arriendo3_placeholder.jpg')
      drawFakeData(space_points, png_path, nil, :demanda, demand_title, {height: fake_data_height, position: GRAPH_POS[:position]})

      # 3 HABITACIONES
      fake_data_height = 178
      space_points = fake_data_height + PADDING * 2
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'disposicion_a_pagar_venta4_placeholder.jpg' : 'disposicion_a_pagar_arriendo4_placeholder.jpg')
      drawFakeData(space_points, png_path, nil, :demanda, demand_title, {height: fake_data_height, position: GRAPH_POS[:position]})

      # 4 HABITACIONES
      fake_data_height = 178
      space_points = fake_data_height + PADDING * 2
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'disposicion_a_pagar_venta5_placeholder.jpg' : 'disposicion_a_pagar_arriendo5_placeholder.jpg')
      drawFakeData(space_points, png_path, nil, :demanda, demand_title, {height: fake_data_height, position: GRAPH_POS[:position]})

    end
  end

  ##############################################################################
  #################             Funciones de graficos          #################
  ##############################################################################
  # Graficos Oferta

  def grafico_area_oferta(modalidad, offer_title = nil, real_data = true)
    # VERIFICAR SI FUNCIONA PARA CASOS EN QUE NO SE TIENE SUFICIENTE INFORMACION
    aux = modalidad == SALE ? "venta" : "arriendo"
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Área promedio (#{aux.capitalize})"
    legend = "<b>Área promedio</b> de cada propiedad en <b>" + aux + "</b>"\
      " en relación a la cantidad de habitaciones."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if real_data
      # CONSULTAS BD
      rooms_area = []
      zero_count = 0
      min_rooms = @type_of_property == [HOUSE] ? HOUSE_MIN_ROOMS : 1
      for rooms in min_rooms..(min_rooms + 3)
        room_area = @stats.properties_mean_area(modalidad, rooms, @type_of_property)
        zero_count += 1 if room_area == 0
        rooms_area << room_area
      end

      if zero_count == rooms_area.size
        # No hay datos
        legend = NO_MESSAGE

      else
        # Hay datos
        # Grafico
        parts << {type: :graph}
      end

      # texto.
      parts << {type: :text, content: legend}

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      # TEXTO
      drawText(legend)

      # GRAFICO
      if zero_count != rooms_area.size
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Área promedio en " + aux
        g.y_axis_label = "Área en m^2"
        g = formatDecimalLabels(aux, g)
        # la funcion acontinuacion retorna un string de error si lo hay y pone la
        # data en el grafico
        errores = data_por_habitacion(rooms_area, g, OFFER)
        g.minimum_value = 0
        g.show_labels_for_bar_values = true
        pad_bottom(PADDING * 2) do 
          image StringIO.new(g.to_blob), GRAPH_POS
        end

        printErrors(errores)
      end

    else
      # parts << {type: :text, content: legend}
      # space_points += getTotalHeight(parts)

      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'area_promedio_arriendo_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title)

    end
  end

  def grafico_ppm_oferta(modalidad, offer_title = nil, real_data = true)
    aux = modalidad == SALE ? "venta" : "arriendo"
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Valor por metro cuadrado (#{aux.capitalize})"
    legend = "<b>Valor por metro cuadrado</b> de cada propiedad en <b>" + aux + "</b> en relación a la cantidad de habitaciones."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if real_data
      # CONSULTAS BD
      rooms_ppm = []
      zero_count = 0
      min_rooms = @type_of_property == [HOUSE] ? HOUSE_MIN_ROOMS : 1

      for rooms in min_rooms..(min_rooms + 3)
        room_ppm = @stats.properties_mean_ppm(modalidad, rooms, @type_of_property, @currency_id)
        zero_count += 1 if room_ppm == 0
        rooms_ppm << room_ppm
      end

      if zero_count == rooms_ppm.size
        # No hay datos
        legend = NO_MESSAGE

      else
        # Hay datos
        # Grafico
        parts << {type: :graph}

      end

      # Texto
      parts << {type: :text, content: legend}

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      # TEXTO
      drawText(legend)

      if zero_count != rooms_ppm.size
        # GRAFICO
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Valor m^2 en " + aux
        g.y_axis_label = @currency_name
        errores = data_por_habitacion(rooms_ppm, g, OFFER)
        g.minimum_value = 0
        g = formatDecimalLabels(aux, g)
        g.show_labels_for_bar_values = true
        pad_bottom(PADDING * 2) do 
          image StringIO.new(g.to_blob), GRAPH_POS
        end

        printErrors(errores)
      end
      
    else
      # parts << {type: :text, content: legend}
      # space_points += getTotalHeight(parts)

      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'valor_pmm_venta_placeholder.jpg' : 'valor_pmm_arriendo_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title)
      
    end
  end

  def grafico_valor_oferta(modalidad, offer_title = nil, real_data = nil)
    aux = modalidad == SALE ? "venta" : "arriendo"
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Precio promedio (#{aux.capitalize})"
    legend = "<b>Valor promedio</b> en #{@currency_name} de las propiedades en"\
      " <b>#{aux}</b> en relación a la cantidad de habitaciones, durante todo el periodo analizado."
    space_points = 0
    parts = []

    # Titulo oferta y subtitulo.
    parts << {type: :offer_title, content: offer_title}
    parts << {type: :sub_title, content: title}

    if real_data
      # CONSULTAS BD
      rooms_price = []
      zero_count = 0
      min_rooms = @type_of_property == [HOUSE] ? HOUSE_MIN_ROOMS : 1

      for rooms in min_rooms..(min_rooms + 3)
        room_price = @stats.properties_mean_price(modalidad, rooms, @type_of_property, @currency_id)
        zero_count += 1 if room_price == 0
        rooms_price << room_price
      end

      if zero_count == rooms_price.size
        # No hay datos
        legend = NO_MESSAGE

      else
        # Hay datos
        # Grafico
        parts << {type: :graph}
      end

      # Texto
      parts << {type: :text, content: legend}

      # CHECKEAR ESPACIO EN LA PAGINA
      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO OFERTA
      drawOfferTitle(offer_title)

      # TITULO
      drawSubTitle(title, :oferta)

      # TEXTO
      drawText(legend)

      if zero_count != rooms_price.size
        # GRAFICO
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Precio promedio en #{aux}"
        g.y_axis_label = @currency_name
        g = formatDecimalLabels(aux, g)
        errores = data_por_habitacion(rooms_price, g, OFFER)
        g.minimum_value = 0
        g.show_labels_for_bar_values = true
        pad_bottom(PADDING * 2) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end

        printErrors(errores)
      end

    else
      # parts << {type: :text, content: legend}
      # space_points += getTotalHeight(parts)

      png_path = Rails.root.join('app', 'pdfs', 'placeholders', 'precio_promedio_arriendo_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :oferta, offer_title, {height: 223})

    end
  end

  def grafico_vacancia(months, dates, sales_data, rents_data)
    # HACER EL CASO EN QUE SE DAN LOS MESES COMO PARAMETRO
    g = Gruff::Bar.new
    g.labels = {
      0 => (MESES_CORTO[months[0]] + " " + dates[0][0].year.to_s),
      1 => (MESES_CORTO[months[1]] + " " + dates[1][0].year.to_s),
      2 => (MESES_CORTO[months[2]] + " " + dates[2][0].year.to_s)
    }
    g.theme = GRAPH_STYLE
    g.title = "Tasa de vacancia mensual"
    g.y_axis_label = "Porcentaje de vacancia (%)"
    g.data("Venta", sales_data)
    g.data("Arriendo", rents_data)
    g = formatDecimalLabels('venta', g)
    g.show_labels_for_bar_values = true
    g.minimum_value = 0
    pad_bottom(PADDING * 2) do
      image StringIO.new(g.to_blob), GRAPH_POS
    end
  end

  ##############################################################################
  # Graficos Demanda

  def grafico_area_demanda(modalidad, rooms_data)
    aux = modalidad == SALE ? "Venta" : "Arriendo"

    title = "Área promedio en m^2 (#{aux})"
    graph = Scruffy::Graph.new(:title => title,theme: Scruffy::Themes::Base.new({background: 'transparent', colors: GRAPH_STYLE[:colors], marker: GRAPH_STYLE[:marker_color], grid_stroke: 0.5, labels: ['1+ hab', '2+ hab', '3+ hab', '4+ hab']}))

    graph.renderer = Scruffy::Renderers::Standard.new
    a = graph.add(:bar, 'Normal', rooms_data[1][1], custom_colors: true)
    graph << Scruffy::Layers::Line.new(:title => 'Inferior1', :points => rooms_data[0][1], stroke_width: 10, shadow: false, only_dots: true, dot_radius: 1, bar: a, limit_lines: true)
    graph.add(:line, 'Superior', rooms_data[2][1], bar: a, limit_lines: true, only_dots: true, dot_radius: 1)
    
    image StringIO.new(graph.render(:width => 800, min_value: 0, :as=>'PNG')), GRAPH_POS
  end

  def max_precios_promedio(modalidad, demand_title = nil)
    aux = modalidad == SALE ? "venta" : "arriendo"
    title = @num_title.to_s + "." + @num_subtitle.to_s + " Disposición a pagar (#{aux.capitalize})"
    legend = "Precio promedio máximo para <b>#{aux}</b> que se está dispuesto a pagar:"
    space_points = 0
    parts = []

    # ALTURA TITULO DEMANDA
    parts << {type: :offer_title, content: demand_title}
    # ALTURA TITULO
    parts << {type: :sub_title, content: title}

    if @complete_graph # SOLO PARA GRAFICO COMPLETO
      # CONSULTAS BD
      pass = false
      rooms_means = []
      zero_count = 0
      for rooms in 1..4
        room_mean = @stats.zones_mean_price(modalidad, rooms, @type_of_property, @currency_id)
        zero_count += 1 if room_mean.nan?
        rooms_means << room_mean
      end

      if zero_count != rooms_means.size
        # Hay datos
        pass = true
        # ALTURA GRAFICO
        parts << {type: :graph, middle_graph: true}

      else
        # No hay datos
        legend = NO_MESSAGE
      end
      
      # ALTURA TEXTO
      parts << {type: :text, content: legend}

      space_points += getTotalHeight(parts)
      checkPageSkip(space_points)

      # TITULO DEMANDA
      drawDemandTitle(demand_title)

      # TITULO
      drawSubTitle(title, :demanda)

      # TEXTO
      drawText(legend)

      if pass
        # GRAFICO
        g = Gruff::Bar.new
        g.theme = GRAPH_STYLE
        g.title = "Precio promedio max - #{aux}"
        data_por_habitacion(rooms_means, g, DEMAND)
        g.minimum_value = 0
        g = formatDecimalLabels(aux, g)
        g.show_labels_for_bar_values = true
        g.y_axis_label = @currency_name
        pad_bottom(PADDING) do
          image StringIO.new(g.to_blob), GRAPH_POS
        end        
      end

    else # SOLO PARA GRAFICO BASICO
      fake_data_height = 211
      space_points += fake_data_height + PADDING * 2
      png_path = Rails.root.join('app', 'pdfs', 'placeholders', modalidad == SALE ? 'disposicion_a_pagar_venta1_placeholder.jpg' : 'disposicion_a_pagar_arriendo1_placeholder.jpg')
      drawFakeData(space_points, png_path, title, :demanda, demand_title, {height: fake_data_height})
    end
  end

  def max_precio_rango(modalidad, habitaciones, separadores_estandar, parts = [], legend = "", last_graph = false)
    if modalidad == SALE
      aux = " - Venta en UF"
      moneda = UF
      signo = ""
    else
      aux = " - Arriendo en Pesos"
      moneda = CL_PESOS
      signo = "$"
    end
    space_points = 0
    graph_title = "Distribución " + habitaciones.to_s +
        (habitaciones == 1 ? " habitación" : " habitaciones") + aux
    separadores = separadores_estandar
    pass = false
    padding = PADDING
    dist = @stats.demand_price_dist(modalidad, habitaciones, @type_of_property, moneda, separadores_estandar)

    if !dist.nil?
      # Hay datos
      pass = true
      # Grafico
      if last_graph
        parts << {type: :graph}
        padding = PADDING * 2

      else
        parts << {type: :graph, middle_graph: true}
      end

    else
      parts = []
      # No hay datos
      legend = "Para el gráfico '<b>#{graph_title}</b>' no se encontraron datos suficientes."
      parts << {type: :text, content: legend}
    end

    if parts.size != 0
      space_points += getTotalHeight(parts)
    end

    checkPageSkip(space_points)

    # Si existe texto, solo se da para el caso del primer grafico de la seccion.
    drawText(legend) if !legend.blank?

    if pass
      g = Gruff::Bar.new
      g.theme = GRAPH_STYLE
      g.title = "Distribución " + habitaciones.to_s +
        (habitaciones == 1 ? " habitación" : " habitaciones") + aux
      g.show_labels_for_bar_values = true
      g = formatDecimalLabels(modalidad, g)
      g.y_axis_label = 'Porcentaje (%) del total'
      g.title_font_size = 32

      if (dist[0])
        s = "Menos de " + ("#{signo}%d" % separadores.first)
        g.data(s, [dist[0]])
      end
      for i in 0..(separadores.size - 2)
        if dist[i + 1]
          s = "#{signo}%d - #{signo}%d" % [separadores[i], separadores[i + 1]]
          g.data(s, [dist[i + 1]])
        end
      end
      if modalidad == SALE
        if dist[dist.size - 1]
          s = "Mas de  " + ("#{signo}%d" % separadores.last)
          g.data(s, [dist[dist.size - 1]])
        end
      end
      pad_bottom(padding) do
        image StringIO.new(g.to_blob), GRAPH_POS
      end
    end # END pass
  end # END max_precio_rango

  def data_por_habitacion(arreglo_habitaciones, g, section)
    #g es un objeto gruff, Retorna un string si hay errores o nil si no hay
    errores = []
    condition = @type_of_property == [HOUSE] and section == OFFER
    min_rooms = condition ? HOUSE_MIN_ROOMS : 1

    # Se va recorriendo por cada cantidad de habitaciones y poniendo la info
    # en el grafico, si no hay datos pone error
    arreglo_habitaciones.each_with_index do |data, index|
      rooms = (min_rooms + index)
      if data and data > 0
        if rooms >= MAX_ROOMS || section == DEMAND
          g.data "#{rooms}+ hab", [data]
        else
          g.data "#{rooms} hab", [data]
        end
      else
        errores << "* Para #{rooms} #{singularPluralStr(rooms)} no hay suficiente información"
      end
    end

    if errores.count != 0
      return errores.join(", ") + "."
    else
      return nil
    end
  end

  def aumentar_precio(modalidad, precios, habitaciones)
    if modalidad == SALE
      for i in 0..(precios.size - 1)
        precios[i] += 1000
      end
    else
      for i in 0..(precios.size - 1)
        if habitaciones == 2
          # precios[i] += 100000
          precios[i] += 50000
        elsif habitaciones == 3
          # precios[i] += 150000
          precios[i] += 50000
        else
          # precios[i] += 250000
          precios[i] += 50000
        end
      end
    end
  end

  # Retorna un string con la ubicacion de la zona en palabras
  def ubicacion
    communes_str = @stats.pluralize_communes
    if @stats.communes.size > 1
      comm_st = " las comunas de "
    elsif communes_str == ""
      comm_st = ""
    else
      comm_st = " la comuna de "
    end
    regions_str = @stats.pluralize_regions
    if @stats.regions.size > 1
      reg_st = " las regiones de "
    elsif regions_str == ""
      reg_st = ""
    else
      reg_st = " la region de "
    end
    country_str = @stats.pluralize_countries
    if @stats.countries.size > 1
      coun_st = " los paises "
    elsif country_str == ""
      coun_st = ""
    else
      coun_st = " el pais "
    end

    s = "La zona elegida se encuentra dentro de " + comm_st + communes_str +
      ", " + reg_st + regions_str +" y " + coun_st + country_str + "."
    return s
  end

end
