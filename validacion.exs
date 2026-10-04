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
    resultado =
      Enum.reduce(lotes, %{validos: [], rechazados: []}, fn lote, acc ->
        case validar_lote(lote, confeccionistas, lineas) do
          {:ok, lote_validado} ->
            %{acc | validos: [lote_validado | acc.validos]}

          {:error, motivo} ->
            lote_con_motivo = Map.put(lote, :motivo, motivo)
            %{acc | rechazados: [lote_con_motivo | acc.rechazados]}
        end
      end)

    # Inverte las listas para mantener el orden original de lectura
    %{
      validos: Enum.reverse(resultado.validos),
      rechazados: Enum.reverse(resultado.rechazados)
    }
  end

end
