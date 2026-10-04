defmodule Util do
  @moduledoc """
  Módulo de utilidades e interacción con el usuario (I/O).
  Maneja la lectura y validación de entrada por consola para lotes adicionales,
  la consulta del comprobante individual y el formateo visual de moneda y tablas.
  """

  @doc """
  Imprime en consola cualquier reporte o mensaje del sistema.
  """
  def mostrar_mensaje(texto) do
    IO.puts(texto)
  end

  @doc """
  Solicita al usuario un lote adicional en una sola línea separada por punto y coma.
  Formato esperado: confeccionista;linea;dia;prendas;defectos (Ej: C03;L2;4;85;3.5)

  Retorna:
  - {:ok, lote} si el formato es válido.
  - {:error, :formato_invalido} si falla el parseo de campos o tipos.
  - :omitido si el usuario presiona Enter sin escribir nada.
  """
  def solicitar_lote_adicional do
    IO.puts("\n" <> String.duplicate("-", 60))
    input =
      IO.gets("Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos) o Enter para omitir: ")
      |> String.trim()

    if input == "" do
      :omitido
    else
      parsear_lote_adicional(input)
    end
  end

  @doc """
  Parsea una cadena con campos separados por ';' y construye el mapa del lote.
  Retorna {:ok, lote} o {:error, :formato_invalido}.
  """
  def parsear_lote_adicional(cadena) do
    campos = String.split(cadena, ";") |> Enum.map(&String.trim/1)

    case campos do
      [confeccionista, linea, dia_str, prendas_str, defectos_str] ->
        with {dia, ""} <- Integer.parse(dia_str),
             {prendas, ""} <- Integer.parse(prendas_str),
             {defectos, ""} <- parsear_numero(defectos_str) do

          lote = %{
            confeccionista: confeccionista,
            linea: linea,
            dia: dia,
            prendas: prendas,
            defectos: defectos
          }

          {:ok, lote}
        else
          _error -> {:error, :formato_invalido}
        end

      _otros ->
        {:error, :formato_invalido}
    end
  end

  @doc """
  Solicita el código de un confeccionista y muestra su comprobante si existe.
  """
  def solicitar_y_mostrar_comprobante(lotes_validos, confeccionistas) do
    IO.puts("\n" <> String.duplicate("=", 60))
    codigo_input =
      IO.gets("Ingrese el código de confeccionista para ver su comprobante individual: ")
      |> String.trim()
      |> String.upcase() # Normaliza el código a mayúsculas (ej: c01 -> C01)

    confeccionista = Map.get(confeccionistas, codigo_input)

    if confeccionista == nil do
      mensaje = ("El confeccionista con código '#{codigo_input}' no existe.")
      {:error, mensaje}
    else
      imprimir_comprobante_individual(codigo_input, confeccionista, lotes_validos)
    end
  end

  @doc """
  Imprime el desglose detallado día a día de un confeccionista.
  """
  def imprimir_comprobante_individual(codigo, confeccionista, lotes_validos) do
    # 1. Construir el detalle diario reutilizando los lotes del día ya filtrados
    desglose_dias =
      for dia <- 1..6 do
        lotes_dia = Liquidacion.filtrar_lotes_diarios_confeccionista(lotes_validos, codigo, dia)

        if Enum.any?(lotes_dia) do
          prendas_dia = Enum.sum_by(lotes_dia, fn lote -> lote.prendas end)
          valor_lotes_dia = Enum.sum_by(lotes_dia, &Liquidacion.calcular_valor_lote/1)
          bono_dia = if prendas_dia >= 120, do: 18_000, else: 0

          %{
            dia: dia,
            prendas: prendas_dia,
            valor_lotes: valor_lotes_dia,
            bono: bono_dia
          }
        else
          nil
        end
      end
      |> Enum.reject(&is_nil/1)

    # 2. Totales calculados con las funciones puras de Liquidacion
    suma_lotes = Liquidacion.calcular_total_semanal(lotes_validos, confeccionista)
    suma_bonos = Liquidacion.calcular_bono_total_semanal(lotes_validos, codigo)
    descuento_alquiler = Liquidacion.calcular_descuento_total_semanal(lotes_validos, confeccionista)

    # Se calcula la resta directa con los valores ya obtenidos
    neto = suma_lotes + suma_bonos - descuento_alquiler

    # 3. Formatear detalle de los días trabajados
    filas_dias =
      if Enum.empty?(desglose_dias) do
        "   (No registró lotes válidos en ningún día de la semana)"
      else
        Enum.map_join(desglose_dias, "\n", fn d ->
          "   - Día #{d.dia}: #{d.prendas} prendas | Valor Lotes: $#{formatear_moneda(d.valor_lotes)} | Bono: $#{formatear_moneda(d.bono)}"
        end)
      end

    # 4. Salida por consola
    mensaje = ("""
    ============================================================
    COMPROBANTE INDIVIDUAL DE LIQUIDACIÓN
    ============================================================
    Confeccionista: #{confeccionista.nombre} [Código: #{codigo}]
    Alquila máquina: #{if Liquidacion.validar_confeccionista_alquila_maquina?(confeccionista), do: "SÍ", else: "NO"}

    Detalle por día trabajado:
    #{filas_dias}

    ------------------------------------------------------------
    Suma de Lotes:          $#{formatear_moneda(suma_lotes)}
    Suma de Bonificaciones: $#{formatear_moneda(suma_bonos)}
    Descuento por Alquiler: -$#{formatear_moneda(descuento_alquiler)}
    ------------------------------------------------------------
    PAGO NETO TOTAL:        $#{formatear_moneda(neto)}
    ============================================================
    """)
    {:ok, mensaje}
  end

  @doc """
  Formatea un monto numérico (entero o flotante) con exactamente 2 decimales.
  Evita notación científica.
  """
  def formatear_moneda(monto) when is_integer(monto) do
    :erlang.float_to_binary(monto * 1.0, decimals: 2)
  end

  def formatear_moneda(monto) when is_float(monto) do
    :erlang.float_to_binary(monto, decimals: 2)
  end

  # Auxiliar para parsear floats o enteros ingresados en la consola
  defp parsear_numero(string) do
    case Float.parse(string) do
      {num, ""} -> {:ok, num}
      _error ->
        case Integer.parse(string) do
          {num, ""} -> {:ok, num * 1.0}
          _error -> :error
        end
    end
  end

  @doc """
  Convierte la lista de confeccionistas a un mapa indexado por código:
  %{"C01" => %{nombre: "María Elena Ríos", alquiler: true}, ...}
  """
  def confeccionistas_mapa(confeccionistas) do
    confeccionistas
    |> Enum.map(fn confeccionista -> {confeccionista.codigo, confeccionista} end)
    |> Enum.into(%{})
  end

  @doc """
  Convierte la lista de líneas a un mapa indexado por ID:
  %{"L1" => %{nombre: "Línea Norte", puestos: 6}, ...}
  """
  def lineas_mapa(lineas) do
    lineas
    |> Enum.map(fn linea -> {linea.id, linea} end)
    |> Enum.into(%{})
  end
end
