Code.require_file("liquidacion.exs")
alias Liquidacion
Code.require_file("util.exs")
alias Util

defmodule Reportes do
  @moduledoc """
  Módulo encargado de generar los reportes solicitados por el taller.
  Contiene funciones para cada reporte.
  """
  @doc """
  Genera e imprime el Reporte R1: Lotes rechazados con su motivo
  y la cantidad de rechazos por cada motivo.
  """
  def generar_reporte_r1(lotes_rechazados) do
    total_rechazados = Enum.count(lotes_rechazados)

    # 1. Formatear el detalle de cada lote rechazado
    detalles_texto =
      if total_rechazados == 0 do
        "  No hay lotes rechazados."
      else
        Enum.map_join(lotes_rechazados, "\n", &formatear_detalle_lote/1)
      end

    # 2. Agrupar y contar la cantidad de rechazos por cada motivo
    resumen_motivos_texto =
      if total_rechazados == 0 do
        "  Sin rechazos registrados."
      else
        lotes_rechazados
        |> Enum.group_by(fn lote -> lote.motivo end)
        |> Enum.map_join("\n", fn {motivo, lotes} ->
          "  - #{formatear_motivo(motivo)}: #{Enum.count(lotes)}"
        end)
      end

    # 3. Impresión final del reporte
    """
    ===================================================
    REPORTE #1 - LOTES RECHAZADOS
    ===================================================

    Total de lotes rechazados: #{total_rechazados}

    Detalle de lotes rechazados:
    #{detalles_texto}

    Cantidad de rechazos por motivo:
    #{resumen_motivos_texto}
    ===================================================
    """
  end

  # Función auxiliar pura para formatear el detalle de un lote con valor por defecto para cuando asi se requiera
  defp formatear_detalle_lote(lote) do
    conf = Map.get(lote, :confeccionista, "N/A")
    linea = Map.get(lote, :linea, "N/A")
    dia = Map.get(lote, :dia, "N/A")
    motivo = formatear_motivo(lote.motivo)

    "  - Motivo: #{motivo} | Confeccionista: #{conf} | Línea: #{linea} | Día: #{dia}"
  end

  # Función auxiliar pura para formatear los átomos de motivo de rechazo a texto
  defp formatear_motivo(:confeccionista_desconocido), do: "Confeccionista desconocido"
  defp formatear_motivo(:linea_desconocida), do: "Línea desconocida"
  defp formatear_motivo(:dia_invalido), do: "Día inválido"
  defp formatear_motivo(:prendas_fuera_de_rango), do: "Prendas fuera de rango"
  defp formatear_motivo(:porcentaje_invalido), do: "Porcentaje de defectos inválido"
  defp formatear_motivo(:formato_invalido), do: "Formato de lote inválido"
  defp formatear_motivo(motivo), do: "#{motivo}"

  @doc """
  Genera e imprime el Reporte R2: Prendas elaboradas por línea y productividad
  semanal en prendas por puesto (prendas/puestos), ordenadas de mayor a menor.
  Incluye líneas sin lotes válidos con 0 prendas.
  """
  def generar_reporte_r2(lotes_validos, lineas) do
    # 1. Agrupar la suma de prendas directamente por línea
    prendas_por_linea =
      lotes_validos
      |> Enum.group_by(fn lote -> lote.linea end)
      |> Enum.map(fn {linea_id, lotes_linea} ->
        {linea_id, Enum.sum_by(lotes_linea, fn lote -> lote.prendas end)}
      end)
      |> Enum.into(%{})

    # 2. Iterar sobre TODAS las líneas registradas para garantizar que no se excluya ninguna
    productividad_por_linea =
      Enum.map(lineas, fn {linea_id, datos_linea} ->
        total_prendas = Map.get(prendas_por_linea, linea_id, 0)
        puestos = datos_linea.puestos

        # Cálculo de productividad (prendas / puestos)
        productividad_semanal = if puestos > 0, do: total_prendas / puestos, else: 0.0

        %{
          linea: linea_id,
          nombre: Map.get(datos_linea, :nombre, "Línea #{linea_id}"),
          prendas: total_prendas,
          puestos: puestos,
          productividad: productividad_semanal
        }
      end)

    # 3. Ordenar de mayor a menor productividad
    productividad_ordenada = Enum.sort_by(productividad_por_linea, & &1.productividad, :desc)

    # 4. Formatear la salida en texto
    filas_texto =
      Enum.map_join(productividad_ordenada, "\n", fn item ->
        prod_formateada = Util.formatear_numero(item.productividad)

        "  - Línea #{item.linea} (#{item.nombre}): #{item.prendas} prendas | #{item.puestos} puestos | Productividad: #{prod_formateada} prendas/puesto"
      end)

    """
    ===================================================
    REPORTE #2 - PRODUCTIVIDAD POR LÍNEA DE PRODUCCIÓN
    ===================================================

    #{filas_texto}
    ===================================================
    """
  end

# Función auxiliar (Reutilizada por R3 y C.2)
@doc """
Calcula el mapa de producción diaria a partir de lotes válidos.
"""
def obtener_produccion_diaria(lotes_validos) do
  lotes_validos
  |> Enum.group_by(fn lote -> lote.dia end)
  |> Enum.map(fn {dia, lotes_dia} ->
    {dia, Enum.sum_by(lotes_dia, fn lote -> lote.prendas end)}
  end)
  |> Enum.into(%{})
end
@doc """
  Genera el Reporte R3: Prendas producidas en cada uno de los 6 días,
  verificando la meta de 600 prendas diarias, e informando si se alcanzó la meta
  al menos un día y si se logró todos los días.
  """
    # 1. Agrupar y sumar las prendas por día directamente en un mapa
    prendas_por_dia_mapa =
      lotes_validos
      |> Enum.group_by(fn lote -> lote.dia end)
      |> Enum.map(fn {dia, lotes_dia} ->
        {dia, Enum.sum_by(lotes_dia, fn lote -> lote.prendas end)}
      end)
      |> Enum.into(%{})

  # 2. Iterar del día 1 al 6 para no omitir días con 0 prendas
  produccion_diaria =
    for dia <- 1..6 do
      total_prendas = Map.get(prendas_por_dia_mapa, dia, 0)
      cumple_meta = total_prendas >= 600

      %{dia: dia, total_prendas: total_prendas, cumple_meta: cumple_meta}
    end

  alcanzo_al_menos_un_dia = Enum.any?(produccion_diaria, fn dia -> dia.cumple_meta end)
  alcanzo_todos_los_dias = Enum.all?(produccion_diaria, fn dia -> dia.cumple_meta end)

  filas_texto =
    Enum.map_join(produccion_diaria, "\n", fn dia ->
      estado = if dia.cumple_meta, do: "SÍ (Meta alcanzada)", else: "NO"
      "  - Día #{dia.dia}: #{dia.total_prendas} prendas | Alcanzó meta (600): #{estado}"
    end)

    """
    ===================================================
    REPORTE #3 - PRODUCCIÓN DIARIA Y METAS DEL TALLER
    ===================================================

  #{filas_texto}

  ---------------------------------------------------
  ¿Se alcanzó la meta de 600 prendas al menos un día?: #{Util.formatear_booleano(alcanzo_al_menos_un_dia)}
  ¿Se alcanzó la meta de 600 prendas todos los días?: #{Util.formatear_booleano(alcanzo_todos_los_dias)}
  ===================================================
  """
end

  @doc """
  Genera e imprime el Reporte R4: Liquidación de todos los confeccionistas,
  numerada y ordenada por pago neto de mayor a menor.
  Muestra prendas totales, valor de lotes, bonificaciones, alquiler y neto.
  """
  def generar_reporte_r4(lotes, confeccionistas) do
    datos_confeccionistas =
      Enum.map(confeccionistas, fn {codigo, confeccionista} ->
        # 1. Filtrar los lotes pertenecientes a este confeccionista (usando Enum.filter)
        lotes_conf = Enum.filter(lotes, fn lote -> lote.codigo_confeccionista == codigo end)

        # 2. Cálculos de liquidación
        total_prendas = Enum.sum_by(lotes_conf, fn l -> l.prendas end)

        # Si confeccionista es un mapa sin el campo :codigo adentro, usas la variable 'codigo' de la tupla:
        conf_con_codigo = Map.put_new(confeccionista, :codigo, codigo)

        bono_total = Liquidacion.calcular_bono_total_semanal(lotes, codigo)
        descuento_alquiler = Liquidacion.calcular_descuento_total_semanal(lotes, conf_con_codigo)

        suma_valor_lotes =
          lotes_conf
          |> Enum.map(&Liquidacion.calcular_valor_lote/1)
          |> Enum.sum()

        neto_semanal = suma_valor_lotes + bono_total - descuento_alquiler

        %{
          nombre: confeccionista.nombre,
          codigo: codigo,
          prendas: total_prendas,
          valor_lotes: suma_valor_lotes,
          bono_total: bono_total,
          descuento_alquiler: descuento_alquiler,
          neto_semanal: neto_semanal
        }
      end)
      |> Enum.sort_by(& &1.neto_semanal, :desc)

    # Ordenar de mayor a menor según el neto semanal

    # 5. Formatear salida numerada
    filas_texto =
      datos_confeccionistas
      |> Enum.with_index(1)
      |> Enum.map_join("\n", fn {confeccionista, index} ->
        "#{index}. [#{confeccionista.codigo}] #{confeccionista.nombre}\n" <>
          "   - Total Prendas: #{confeccionista.prendas}\n" <>
          "   - Valor Lotes:   $#{Util.formatear_numero(confeccionista.valor_lotes)}\n" <>
          "   - Bonificaciones: $#{Util.formatear_numero(confeccionista.bono_total)}\n" <>
          "   - Alquiler:      -$#{Util.formatear_numero(confeccionista.descuento_alquiler)}\n" <>
          "   - Pago Neto:     $#{Util.formatear_numero(confeccionista.neto_semanal)}"
      end)

    """
    ===================================================
    REPORTE #4 - LIQUIDACIÓN SEMANAL DE CONFECCIONISTAS
    ===================================================

    #{filas_texto}
    ===================================================
    """
  end

  @doc """
  R5: muestra el confeccionista que produjo más prendas cada día; si hay empate, se muestran
  todos. Los días sin lotes válidos se indican como tales. Al final se informa quién
  ocupó el primer lugar más días y cuántos; si hay empate, se incluyen todos los empatados.
  """
  def generar_reporte_r5(lotes_validos, mapa_confeccionistas) do
    encabezado = "\nR5. Confeccionista(s) con mas prendas por día:"

    resultados_dias =
      for dia <- 1..6 do
        procesar_dia(dia, lotes_validos, mapa_confeccionistas)
      end

    ganadores_por_dia = Enum.map(resultados_dias, fn {codigos, _mensaje} -> codigos end)
    lineas_dias = Enum.map_join(resultados_dias, "\n", fn {_codigos, mensaje} -> mensaje end)
    resumen = obtener_resumen_general(ganadores_por_dia, mapa_confeccionistas)

    Enum.join([encabezado, lineas_dias, resumen], "\n")
  end

  # Funciones auxiliares para el reporte 5

  @doc """
   Procesa un día y retorna la lista de códigos de los ganadores de ese día
  """
  def procesar_dia(dia, lotes, confeccionistas) do
    # Filtrar solo los lotes de ese día
    lotes_dia = Enum.filter(lotes, fn lot -> lot.dia == dia end)

    if lotes_dia == [] do
      {[], "Día #{dia}: Sin lotes válidos"}
    else
      # Calcular prendas por confeccionista en el día
      prendas_por_conf = calcular_prendas_por_confeccionista(lotes_dia)

      # Hallar el número máximo de prendas producidas
      {_cod, max_prendas} = Enum.max_by(prendas_por_conf, fn {_cod, prendas} -> prendas end)

      # Obtener todos los códigos que alcanzaron ese máximo
      codigos_ganadores =
        prendas_por_conf
        |> Enum.filter(fn {_cod, prendas} -> prendas == max_prendas end)
        |> Enum.map(fn {cod, _prendas} -> cod end)

      nombres = obtener_nombres(codigos_ganadores, confeccionistas)
      mensaje_dia = "Día #{dia}: #{nombres} con #{max_prendas} prendas"

      {codigos_ganadores, mensaje_dia}
    end
  end

  @doc """
   Suma las prendas de cada confeccionista para una lista de lotes dada
  """
  def calcular_prendas_por_confeccionista(lotes) do
    lotes
    |> Enum.group_by(fn l -> l.codigo_confeccionista end)
    |> Enum.map(fn {cod, lista_lotes} ->
      total_prendas = Enum.reduce(lista_lotes, 0, fn lote, acc -> lote.prendas + acc end)

      {cod, total_prendas}
    end)
  end

  @doc """
   Convierte una lista de códigos a los nombres a los cuales corresponden los códigos
  """
  def obtener_nombres(codigos, confeccionistas) do
    codigos
    |> Enum.map(fn cod ->
      nombre = confeccionistas[cod][:nombre] || cod
      "#{nombre} (#{cod})"
    end)
    |> Enum.join(", ")
  end

  @doc """
   Cuenta los días ganados por cada confeccionista y obtiene el líder general
  """
  def obtener_resumen_general(ganadores_por_dia, confeccionistas) do
    todos_los_ganadores = List.flatten(ganadores_por_dia)

    if todos_los_ganadores == [] do
      "\nResumen general: No hubo días con lotes válidos."
    else
      # Contar cuántas veces aparece cada código
      conteo = Enum.frequencies(todos_los_ganadores)
      # Encontrar el número máximo de días ganados
      {_cod, max_dias} = Enum.max_by(conteo, fn {_cod, dias} -> dias end)
      # Filtrar los líderes que tengan ese número máximo de días
      lideres_codigos =
        conteo
        |> Enum.filter(fn {_cod, dias} -> dias == max_dias end)
        |> Enum.map(fn {cod, _dias} -> cod end)

      nombres_lideres = obtener_nombres(lideres_codigos, confeccionistas)

      "\nResumen general:\nConfeccionista(s) en primer lugar con #{max_dias} día(s): #{nombres_lideres}"
    end
  end

  @doc """
  R6: Confeccionista con mejor calidad: menor porcentaje de defectos ponderado por
  prendas entre quienes tengan al menos 3 lotes válidos.
  """
  def generar_reporte_r6(lotes_validos, mapa_confeccionistas) do
    resultado =
      lotes_validos
      |> Enum.group_by(fn l -> l.codigo_confeccionista end)
      |> filtrar_por_minimo_lotes()
      |> calcular_calidad_candidatos()
      |> mostrar_ganador_calidad(mapa_confeccionistas)

    "\nR6. Confeccionista con mejor calidad\n#{resultado}"
  end

  # Funciones auxiliares para el reporte 6

  @doc """
  1. Filtra confeccionistas que tengan al menos 3 lotes válidos
  """
  def filtrar_por_minimo_lotes(lotes_por_conf) do
    Enum.filter(lotes_por_conf, fn {_cod, lotes} -> length(lotes) >= 3 end)
  end

  @doc """
  2. Calcula el porcentaje ponderado y el total de prendas para cada candidato
  """
  def calcular_calidad_candidatos(candidatos_lotes) do
    Enum.map(candidatos_lotes, fn {cod, lotes} ->
      porcentaje = calcular_porcentaje_ponderado(lotes)
      total_prendas = Enum.sum_by(lotes, fn l -> l.prendas end)

      {cod, porcentaje, total_prendas, length(lotes)}
    end)
  end

  @doc """
  3. Aplica la fórmula del promedio ponderado: suma(defectos * prendas) / suma(prendas)
  """
  def calcular_porcentaje_ponderado(lotes) do
    suma_defectos_prendas = Enum.sum_by(lotes, fn l -> l.defectos * l.prendas end)
    total_prendas = Enum.sum_by(lotes, fn l -> l.prendas end)

    suma_defectos_prendas / total_prendas
  end

  @doc """
  4. Determina el porcentaje mínimo e imprime el o los ganadores
  """
  def mostrar_ganador_calidad([], _mapa_confeccionistas) do
    "Ningún confeccionista cumple con el mínimo de 3 lotes válidos."
  end

  def mostrar_ganador_calidad(candidatos, mapa_confeccionistas) do
    # Encontrar el menor porcentaje de defectos
    {_cod, min_porcentaje, _, _} = Enum.min_by(candidatos, fn {_cod, pct, _, _} -> pct end)

    # Filtrar todos los que empaten en el primer lugar
    ganadores = Enum.filter(candidatos, fn {_cod, pct, _, _} -> pct == min_porcentaje end)

    Enum.map_join(ganadores, "\n", fn {cod, pct, prendas, num_lotes} ->
      datos_conf = Map.get(mapa_confeccionistas, cod, %{})
      nombre = Map.get(datos_conf, :nombre, cod)

      "Confeccionista: #{nombre} (#{cod})\nPorcentaje ponderado de defectos: #{pct}%\nLotes válidos: #{num_lotes} | Total prendas: #{prendas}"
    end)
  end

  @doc """
  R7. Total que debe pagar el taller durante la semana y costo promedio pagado
  por prenda válida (total pagado / total de prendas válidas). Si no hay prendas válidas,
  indica que el promedio no puede calcularse.
  """
  def generar_reporte_r7(lotes_validos, mapa_confeccionistas) do
    total_pagado = calcular_total_pagado_taller(lotes_validos, mapa_confeccionistas)
    total_prendas = calcular_total_prendas_validas(lotes_validos)
    promedio_texto = calcular_y_formatear_promedio(total_pagado, total_prendas)

    "\nR7. Total semanal del taller y costo promedio por prenda\nTotal a pagar por el taller: $#{Util.formatear_numero(total_pagado)}\nTotal prendas válidas: #{total_prendas}\n#{promedio_texto}"
  end

  # Funciones auxiliares para el reporte 7

  @doc """
  Suma el pago neto total que el taller debe pagar a todos los confeccionistas
  """
  def calcular_total_pagado_taller(lotes, mapa_confeccionistas) do
    mapa_confeccionistas
    |> Map.values()
    |> Enum.sum_by(fn confeccionista ->
      Liquidacion.calcular_neto_semanal(lotes, confeccionista)
    end)
  end

  @doc """
  Suma la cantidad total de prendas válidas producidas en la semana
  """
  def calcular_total_prendas_validas(lotes) do
    Enum.sum_by(lotes, fn lote -> lote.prendas end)
  end

  @doc """
  Calcula el costo promedio por prenda válida o indica que no es posible calcularlo
  """
  def calcular_y_formatear_promedio(_total_pagado, 0) do
    "Costo promedio por prenda válida: El promedio no puede calcularse."
  end

  def calcular_y_formatear_promedio(total_pagado, total_prendas) do
    promedio = total_pagado / total_prendas
    "Costo promedio por prenda válida: $#{Util.formatear_numero(promedio)}"
  end

  @doc """
  R8: Confeccionistas que elaboraron al menos un lote válido en todas las líneas de producción.
  Si no hay ninguno, debe indicarse.
  """
  def generar_reporte_r8(lotes_validos, mapa_confeccionistas, mapa_lineas) do
    lineas_totales = Map.keys(mapa_lineas)

    resultado =
      lotes_validos
      |> Enum.group_by(fn l -> l.codigo_confeccionista end)
      |> filtrar_confeccionistas_todas_las_lineas(lineas_totales)
      |> formatear_resultado_r8(mapa_confeccionistas)

    "\nR8. Confeccionistas con lotes válidos en todas las líneas\n#{resultado}"
  end

  # Funciones auxiliares para el reporte 8

  @doc """
  Filtra los confeccionistas que hayan registrado al menos un lote en cada línea de producción
  """
  def filtrar_confeccionistas_todas_las_lineas(lotes_por_conf, lineas_totales) do
    Enum.filter(lotes_por_conf, fn {_cod, lotes} ->
      trabajo_en_todas_las_lineas?(lotes, lineas_totales)
    end)
  end

  @doc """
  Verifica si en la lista de lotes de un confeccionista están presentes todas las líneas registradas
  """
  def trabajo_en_todas_las_lineas?(lotes, lineas_totales) do
    lineas_trabajadas = Enum.map(lotes, fn l -> l.linea end)

    Enum.all?(lineas_totales, fn linea ->
      linea in lineas_trabajadas
    end)
  end

  @doc """
  Formatea la lista de confeccionistas que cumplieron la condición o indica que no hubo ninguno[cite: 17]
  """
  def formatear_resultado_r8([], _mapa_confeccionistas) do
    "Ningún confeccionista elaboró lotes válidos en todas las líneas de producción."
  end

  def formatear_resultado_r8(confeccionistas_cumplen, mapa_confeccionistas) do
    Enum.map_join(confeccionistas_cumplen, "\n", fn {cod, _lotes} ->
      datos_conf = Map.get(mapa_confeccionistas, cod, %{})
      nombre = Map.get(datos_conf, :nombre, cod)

      "Confeccionista: #{nombre} (#{cod})"
    end)
  end

  def generar_reportes(lotes_validos, lotes_rechazados, confeccionistas, lineas) do
    reporte1 = generar_reporte_r1(lotes_rechazados)
    reporte2 = generar_reporte_r2(lotes_validos, lineas)
    reporte3 = generar_reporte_r3(lotes_validos)
    reporte4 = generar_reporte_r4(lotes_validos, confeccionistas)
    reporte5 = generar_reporte_r5(lotes_validos, confeccionistas)
    reporte6 = generar_reporte_r6(lotes_validos, confeccionistas)
    reporte7 = generar_reporte_r7(lotes_validos, confeccionistas)
    reporte8 = generar_reporte_r8(lotes_validos, confeccionistas, lineas)

    Enum.join(
      [reporte1, reporte2, reporte3, reporte4, reporte5, reporte6, reporte7, reporte8],
      "\n\n"
    )
  end

@doc """
C.1. Genera un ranking configurable de confeccionistas.
Opciones:
  - :campo  -> :neto (predeterminado), :prendas o :bruto
  - :orden  -> :desc (predeterminado) o :asc
  - :limite -> entero positivo (por defecto muestra todos)
"""
def ranking(liquidaciones, opciones \\ []) do
  campo = Keyword.get(opciones, :campo, :neto)
  orden = Keyword.get(opciones, :orden, :desc)
  limite = Keyword.get(opciones, :limite, nil)

  # 1. Ordenar la lista según el campo y orden solicitado
  liquidaciones_ordenadas =
    Enum.sort_by(
      liquidaciones,
      fn liq -> Map.get(liq, campo, 0) end,
      if(orden == :asc, do: :asc, else: :desc)
    )

  # 2. Aplicar el límite si fue especificado
  resultado =
    if is_integer(limite) and limite > 0 do
      Enum.take(liquidaciones_ordenadas, limite)
    else
      liquidaciones_ordenadas
    end

  # 3. Retornar el texto formateado
  formatear_ranking(resultado, campo, orden)
end

# Función auxiliar para dar formato de texto al ranking
defp formatear_ranking(liquidaciones, campo, orden) do
  encabezado = "\n=== RANKING DE CONFECCIONISTAS (Campo: #{campo} | Orden: #{orden}) ==="

  filas =
    Enum.map_join(liquidaciones, "\n", fn liq ->
      valor = Map.get(liq, campo, 0)

      valor_str =
        if campo == :prendas do
          "#{valor} prendas"
        else
          "$#{Util.formatear_numero(valor)}"
        end

      "Confeccionista: #{liq.nombre} (#{liq.codigo}) -> #{campo}: #{valor_str}"
    end)

  "#{encabezado}\n#{filas}"
  end

@doc """
C.2. Recibe los lotes válidos de R3 y los combina con el mapa del taller aliado.
"""
def combinar_produccion_talleres(lotes_validos, taller_aliado) do
  # Obtiene el mapa del reporte 3
  taller_propio = obtener_produccion_diaria(lotes_validos)

  # Combina sumando las prendas en los días comunes
  Map.merge(taller_propio, taller_aliado, fn _dia, prendas_t1, prendas_t2 ->
    prendas_t1 + prendas_t2
  end)
end
end
