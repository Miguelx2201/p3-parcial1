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
end
