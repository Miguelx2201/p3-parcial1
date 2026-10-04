defmodule Reportes58 do
@doc """
R5: muestra el confeccionista que produjo más prendas cada día; si hay empate, se muestran
todos. Los días sin lotes válidos se indican como tales. Al final se informa quién
ocupó el primer lugar más días y cuántos; si hay empate, se incluyen todos los empatados.
"""
def generar_reporte_5(lotes_validos, mapa_confeccionistas) do
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

  #Funciones auxiliares para el reporte 5

  @doc """
   Procesa un día y retorna la lista de códigos de los ganadores de ese día
  """
  defp procesar_dia(dia, lotes, confeccionistas) do
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
  defp calcular_prendas_por_confeccionista(lotes) do
    lotes
    |> Enum.group_by(fn l -> l.confeccionista end)
    |> Enum.map(fn {cod, lista_lotes} ->
      total_prendas = Enum.reduce(lista_lotes, 0, fn lote, acc -> lote.prendas + acc end)

      {cod, total_prendas}
    end)
  end

  @doc """
   Convierte una lista de códigos a los nombres a los cuales corresponden los códigos
  """
  defp obtener_nombres(codigos, confeccionistas) do
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
  defp obtener_resumen_general(ganadores_por_dia, confeccionistas) do
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
  def generar_reporte_6(lotes_validos, mapa_confeccionistas) do
    resultado =
      lotes_validos
      |> Enum.group_by(fn l -> l.confeccionista end)
      |> filtrar_por_minimo_lotes()
      |> calcular_calidad_candidatos()
      |> mostrar_ganador_calidad(mapa_confeccionistas)

    "\nR6. Confeccionista con mejor calidad\n#{resultado}"
  end

  # Funciones auxiliares para el reporte 6

  @doc """
  1. Filtra confeccionistas que tengan al menos 3 lotes válidos
  """
  defp filtrar_por_minimo_lotes(lotes_por_conf) do
    Enum.filter(lotes_por_conf, fn {_cod, lotes} -> length(lotes) >= 3 end)
  end

  @doc """
  2. Calcula el porcentaje ponderado y el total de prendas para cada candidato
  """
  defp calcular_calidad_candidatos(candidatos_lotes) do
    Enum.map(candidatos_lotes, fn {cod, lotes} ->
      porcentaje = calcular_porcentaje_ponderado(lotes)
      total_prendas = Enum.sum_by(lotes, fn l -> l.prendas end)

      {cod, porcentaje, total_prendas, length(lotes)}
    end)
  end

  @doc """
  3. Aplica la fórmula del promedio ponderado: suma(defectos * prendas) / suma(prendas)
  """
  defp calcular_porcentaje_ponderado(lotes) do
    suma_defectos_prendas = Enum.sum_by(lotes, fn l -> l.defectos * l.prendas end)
    total_prendas = Enum.sum_by(lotes, fn l -> l.prendas end)

    suma_defectos_prendas / total_prendas
  end

  @doc """
  4. Determina el porcentaje mínimo e imprime el o los ganadores
  """
  defp mostrar_ganador_calidad([], _mapa_confeccionistas) do
    "Ningún confeccionista cumple con el mínimo de 3 lotes válidos."
  end

  defp mostrar_ganador_calidad(candidatos, mapa_confeccionistas) do
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
indica que el promedio no puede calcularse[cite: 16].
"""
def generar_reporte_7(lotes_validos, mapa_confeccionistas) do
  total_pagado = calcular_total_pagado_taller(lotes_validos, mapa_confeccionistas)
  total_prendas = calcular_total_prendas_validas(lotes_validos)
  promedio_texto = calcular_y_formatear_promedio(total_pagado, total_prendas)

  "\nR7. Total semanal del taller y costo promedio por prenda\nTotal a pagar por el taller: $#{Util.formatear_moneda(total_pagado)}\nTotal prendas válidas: #{total_prendas}\n#{promedio_texto}"
end

# Funciones auxiliares para el reporte 7

@doc """
Suma el pago neto total que el taller debe pagar a todos los confeccionistas
"""
defp calcular_total_pagado_taller(lotes, mapa_confeccionistas) do
  mapa_confeccionistas
  |> Map.values()
  |> Enum.sum_by(fn confeccionista -> Liquidacion.calcular_neto_semanal(lotes, confeccionista) end)
end

@doc """
Suma la cantidad total de prendas válidas producidas en la semana
"""
defp calcular_total_prendas_validas(lotes) do
  Enum.sum_by(lotes, fn lote -> lote.prendas end)
end

@doc """
Calcula el costo promedio por prenda válida o indica que no es posible calcularlo
"""
defp calcular_y_formatear_promedio(_total_pagado, 0) do
  "Costo promedio por prenda válida: El promedio no puede calcularse."
end

defp calcular_y_formatear_promedio(total_pagado, total_prendas) do
  promedio = total_pagado / total_prendas
  "Costo promedio por prenda válida: $#{Util.formatear_moneda(promedio)}"
end


end
