defmodule Reportes do

  def generar_reporte_r1(lotes_rechazados) do
    Util.mostrar_mensaje("""
    REPORTE #1 - LOTES RECHAZADOS
    =============================

    Lotes rechazados: #{Enum.count(lotes_rechazados)}

    Detalles de lotes rechazados:
    #{Enum.map_join(lotes_rechazados, "\n", fn lote ->
      "Motivo: #{lote.motivo} - Confeccionista: #{lote.confeccionista_codigo} - Linea: #{lote.linea}"
    end)}

    Numero de lotes rechazados por motivo:
    #{Enum.map_join(Enum.group_by(lotes_rechazados, & &1.motivo), "\n", fn {motivo, lotes} ->
      "#{motivo}: #{Enum.count(lotes)}"
    end)}
    """)
  end

  def generar_reporte_r2(lotes, lineas) do
    lotes_por_lineas = Enum.group_by(lotes, &(&1.linea), fn lote -> lote.prendas end)
    productividad_por_linea = Enum.map(lotes_por_lineas, fn {linea, prendas} ->
      total_prendas = Enum.sum(prendas)
      productividad_semanal = total_prendas / Map.get(lineas, linea).puestos
      %{linea: linea, prendas: total_prendas, productividad: productividad_semanal}
    end)
    productividad_por_linea_ordenada = Enum.sort_by(productividad_por_linea, & &1.productividad, :desc)
    Util.mostrar_mensaje("""
    REPORTE #2 - PRODUCTIVIDAD POR LINEA
    ====================================
    #{Enum.map_join(productividad_por_linea_ordenada, "\n", fn %{linea: linea, prendas: prendas, productividad: productividad} ->
      "Linea: #{linea} - Prendas: #{prendas} - Productividad semanal: #{Float.round(productividad, 2)}"
    end)}
    """)
  end
  
end
