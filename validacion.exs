defmodule Validacion do
  @doc """
  Función principal de validación: Encadena secuencialmente las 5 reglas usando with.
  Si alguna regla falla, la ejecución se detiene y retorna el primer error encontrado.
  """
  def validar_lote(lote, confeccionistas, lineas) do
    with :ok <- validar_confeccionista(lote.codigo_confeccionista, confeccionistas),
         :ok <- validar_linea(lote.linea, lineas),
         :ok <- validar_dia(lote.dia),
         :ok <- validar_prendas(lote.prendas),
         :ok <- validar_defectos(lote.defectos) do
      {:ok, lote}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  @doc """
  Verifica que el mapa de confeccionistas tenga la clave del codigo de un cofeccionista.
  De lo contrario, devuelve el error: :confeccionista_desconocido
  """
  defp validar_confeccionista(cod_conf, confeccionistas) do
    cond do
      Map.has_key?(confeccionistas, cod_conf) -> :ok
      true -> {:error, :confeccionista_desconocido}
    end
  end

  @doc """
  Valida que el codigo de la linea que entra como parámetro esté dentro del mapa de lineas.
  De lo contrario, devuelve el error: :linea_desconocida
  """
  defp validar_linea(cod_linea, lineas) do
    cond do
      Map.has_key?(lineas, cod_linea) -> :ok
      true -> {:error, :linea_desconocida}
    end
  end

  @doc """
  Valida que el dia ingresado en la funcion sea un número entero del 1 al 6.
  De lo contrario, devuelve el error: :dia_invalido
  """
  defp validar_dia(dia) do
    cond do
      is_integer(dia) and dia >= 1 and dia <= 6 -> :ok
      true -> {:error, :dia_invalido}
    end
  end

  @doc """
  Valida que el numero de prendas ingresadas sean un entero entre 1 y 180.
  De lo contrario, devuelve el error: :prendas_fuera_de_rango
  """
  defp validar_prendas(prendas) do
    cond do
      is_integer(prendas) and prendas >= 1 and prendas <= 180 -> :ok
      true -> {:error, :prendas_fuera_de_rango}
    end
  end

  @doc """
  Valida que el porcenttaje de defectos ingresado sea un número de 0 a 100.
  De lo contrario, devuelve el error: :porcentaje_invalido
  """
  defp validar_defectos(defectos) do
    cond do
      is_number(defectos) and defectos >= 0 and defectos <= 100 -> :ok
      true -> {:error, :porcentaje_invalido}
    end
  end

@doc """
Procesa una lista de todo tipo de lotes y devuelve un mapa con los lotes validos y los rechazados separados.
"""
def separar_lotes(lotes, confeccionistas, lineas) do
  Enum.reduce(lotes, %{validos: [], rechazados: []}, fn lote, acc ->
    case validar_lote(lote, confeccionistas, lineas) do
        {:ok, lote_validado} ->
        %{acc | validos: [lote_validado | acc.validos]}

        {:error, motivo} ->
        %{acc | rechazados: [lote_rechazado | acc.rechazados]}
        end
      end)
    end

  @doc """
  Valida el lote adicional ingresado por consola, primero lo parsea como un lote normal
  y luego lo valida con el metodo validar_lote
  """
  def validar_lote_adicional(lote_adicional, mapa_confeccionistas, mapa_lineas) do
    case parsear_lote_adicional(lote_adicional) do
      {:ok, lote_mapa} -> validar_lote(lote_mapa, mapa_confeccionistas, mapa_lineas)

      {:error, motivo} -> {:error, motivo}
    end
  end

  @doc """
  Parsea el lote ingresado por consola, primero confirma si es una cadena con el when is_binary,
  vuelve la cadena una lista de strings y si tiene los 5 elementos lo convierte en mapa y devuelve una tupla {:ok, lote},
  de lo contrario devuelve una tupla con  {:error, :formato_invalido}
  """
  defp parsear_lote_adicional(cadena) when is_binary(cadena) do
    partes =
      cadena
      |> String.trim()
      |> String.split(";")
      |> Enum.map(&String.trim/1)

    case partes do
      [cod_conf, cod_linea, str_dia, str_prendas, str_defectos] ->
        try do
          lote_mapa = %{
            codigo_confeccionista: cod_conf,
            linea: cod_linea,
            dia: String.to_integer(str_dia),
            prendas: String.to_integer(str_prendas),
            defectos: parsear_numero(str_defectos)
          }
          {:ok, lote_mapa}
        rescue
          ArgumentError -> {:error, :formato_invalido}
        end

      _elementos_incorrectos ->
        {:error, :formato_invalido}
    end
  end

  @doc """
  Si no ingresa una cadena devuelve {:error, :formato_invalido}
  """
  defp parsear_lote_string(_no_string), do: {:error, :formato_invalido}

  @doc """
  Parsea el numero que ingrese para el porcentaje si tiene un punto a float.
  """
  defp parsear_numero(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      String.to_integer(str)
    end
  end


end
