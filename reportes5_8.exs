defmodule Reportes58 do
@doc """
R5: muestra el confeccionista que produjo más prendas cada día; si hay empate, se muestran
todos. Los días sin lotes válidos se indican como tales. Al final se informa quién
ocupó el primer lugar más días y cuántos; si hay empate, se incluyen todos los empatados.
"""
def reporte_5(lotes_validos, mapa_confeccionistas) do
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


end
