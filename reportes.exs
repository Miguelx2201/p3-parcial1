Code.require_file("liquidacion.exs")
alias Liquidacion
Code.require_file("util.exs")
alias Util
defmodule Reportes do

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
    ("""
    ===================================================
    REPORTE #1 - LOTES RECHAZADOS
    ===================================================

    Total de lotes rechazados: #{total_rechazados}

    Detalle de lotes rechazados:
    #{detalles_texto}

    Cantidad de rechazos por motivo:
    #{resumen_motivos_texto}
    ===================================================
    """)
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
        prod_formateada = :erlang.float_to_binary(item.productividad * 1.0, decimals: 2)
        "  - Línea #{item.linea} (#{item.nombre}): #{item.prendas} prendas | #{item.puestos} puestos | Productividad: #{prod_formateada} prendas/puesto"
      end)

    ("""
    ===================================================
    REPORTE #2 - PRODUCTIVIDAD POR LÍNEA DE PRODUCCIÓN
    ===================================================

    #{filas_texto}
    ===================================================
    """)
  end

  @doc """
  Genera e imprime el Reporte R3: Prendas producidas en cada uno de los 6 días,
  verificando la meta de 600 prendas diarias, e informando si se alcanzó la meta
  al menos un día y si se logró todos los días.
  """
  def generar_reporte_r3(lotes_validos) do
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

    # 3. Evaluaciones globales sobre los 6 días
    alcanzo_al_menos_un_dia = Enum.any?(produccion_diaria, fn dia -> dia.cumple_meta end)
    alcanzo_todos_los_dias = Enum.all?(produccion_diaria, fn dia -> dia.cumple_meta end)

    # 4. Formatear las líneas de texto
    filas_texto =
      Enum.map_join(produccion_diaria, "\n", fn dia ->
        estado = if dia.cumple_meta, do: "SÍ (Meta alcanzada)", else: "NO"
        "  - Día #{dia.dia}: #{dia.total_prendas} prendas | Alcanzó meta (600): #{estado}"
      end)

    ("""
    ===================================================
    REPORTE #3 - PRODUCCIÓN DIARIA Y METAS DEL TALLER
    ===================================================

    #{filas_texto}

    ---------------------------------------------------
    ¿Se alcanzó la meta de 600 prendas al menos un día?: #{Util.formatear_booleano(alcanzo_al_menos_un_dia)}
    ¿Se alcanzó la meta de 600 prendas todos los días?: #{Util.formatear_booleano(alcanzo_todos_los_dias)}
    ===================================================
    """)
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
        lotes_conf = Enum.filter(lotes, fn lote -> lote.confeccionista == codigo end)

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
        "   - Valor Lotes:   $#{Util.formatear_moneda(confeccionista.valor_lotes)}\n" <>
        "   - Bonificaciones: $#{Util.formatear_moneda(confeccionista.bono_total)}\n" <>
        "   - Alquiler:      -$#{Util.formatear_moneda(confeccionista.descuento_alquiler)}\n" <>
        "   - Pago Neto:     $#{Util.formatear_moneda(confeccionista.neto_semanal)}"
      end)

    ("""
    ===================================================
    REPORTE #4 - LIQUIDACIÓN SEMANAL DE CONFECCIONISTAS
    ===================================================

    #{filas_texto}
    ===================================================
    """)
  end

  def probar_reportes_1_4() do
    lotes_rechazados = [
      %{motivo: :confeccionista_desconocido, confeccionista: "C1", linea: "L1", prendas: 100, dia: 1, defectos: 2.0},
      %{motivo: :prendas_fuera_de_rango, confeccionista: "C2", linea: "L1", prendas: 150, dia: 1, defectos: 5.0},
      %{motivo: :prendas_fuera_de_rango, confeccionista: "C3", linea: "L2", prendas: 200, dia: 2, defectos: 8.0}
    ]

    lotes = [
      %{confeccionista: "C1", linea: "L1", prendas: 1000, dia: 1, defectos: 1.0},
      %{confeccionista: "C2", linea: "L2", prendas: 150, dia: 1, defectos: 3.0},
      %{confeccionista: "C3", linea: "L2", prendas: 200, dia: 2, defectos: 6.0},
      %{confeccionista: "C1", linea: "L1", prendas: 250, dia: 2, defectos: 11.0}
    ]

    lineas = %{
      "L1" => %{id: "L1", nombre: "Linea norte", puestos: 10},
      "L2" => %{id: "L2", nombre: "Linea sur", puestos: 15}
    }

    confeccionistas = %{
      "C1" => %{codigo: "C1", nombre: "Juan", alquiler: true},
      "C2" => %{codigo: "C2", nombre: "Maria", alquiler: false},
      "C3" => %{codigo: "C3", nombre: "Pedro", alquiler: false}
    }

    reporte1 = Reportes.generar_reporte_r1(lotes_rechazados)
    reporte2 = Reportes.generar_reporte_r2(lotes, lineas)
    reporte3 = Reportes.generar_reporte_r3(lotes)
    reporte4 = Reportes.generar_reporte_r4(lotes, confeccionistas)
    reportes = reporte1 <> "\n\n" <> reporte2 <> "\n\n" <> reporte3 <> "\n\n" <> reporte4
    Util.mostrar_mensaje(reportes)
  end
end
Reportes.probar_reportes_1_4()
