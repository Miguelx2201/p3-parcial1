Code.require_file("util.exs", __DIR__)
alias Util

defmodule Mediciones do
  @moduledoc """
  Módulo de pruebas de rendimientoy análisis de eficiencia algorítmica.
  Realiza experimentos empíricos para comparar: la búsqueda de elementos y la construcción de colecciones
  """

  def main do
    medicion1()
    medicion2()
  end

  @doc """
  **Experimento 1: Compara el tiempo de búsqueda entre una Lista y un Mapa.
  Construye una colección de 100.000 confeccionistas y realiza 1.000 búsquedas aleatorias.
  """
  def medicion1() do
    confeccionistas_lista =
      Enum.map(1..100_000, fn i ->
        %{
          codigo: "C#{i}",
          nombre: "Confeccionista #{i}",
          alquiler: rem(i, 2) == 0
        }
      end)

    confeccionistas_mapa =
      Enum.map(confeccionistas_lista, fn confeccionista -> {confeccionista.codigo, confeccionista} end)
      |> Enum.into(%{})

    codigos_para_buscar = Enum.map(1..1_000, fn _ -> "C#{Enum.random(1..100_000)}" end)

    {tiempo_lista, _resultado} = :timer.tc(fn ->
      Enum.each(codigos_para_buscar, fn codigo ->
        Enum.find(confeccionistas_lista, fn confeccionista -> confeccionista.codigo == codigo end)
      end)
    end)

    {tiempo_mapa, _resultado} = :timer.tc(fn ->
      Enum.each(codigos_para_buscar, fn codigo ->
        Map.get(confeccionistas_mapa, codigo)
      end)
    end)

    milisegundos_lista = tiempo_lista / 1000 |> Util.formatear_numero()

    milisegundos_mapa = tiempo_mapa / 1000 |> Util.formatear_numero()

    """
    ===================================================
    EXPERIMENTO 1
    ===================================================
    Mediciones lista:
    #{milisegundos_lista}

    Mediciones mapa:
    #{milisegundos_mapa}
    ===================================================
    """
    |> Util.mostrar_mensaje()
  end

  @doc """
  Experimento 2: Compara la acumulación de 20.000 elementos mediante concatenación vs inserción al inicio.
  """
  def medicion2() do
    {tiempo_al_final, _resultado} = :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn elemento, acomulador -> acomulador ++ [elemento] end)
      end)

    {tiempo_al_inicio, _resultado} = :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn elemento, acomulador -> [elemento | acomulador] end)
      end)

    milisegundos_al_final = tiempo_al_final / 1000 |> Util.formatear_numero()

    milisegundos_al_inicio = tiempo_al_inicio / 1000 |> Util.formatear_numero()

    """
    ===================================================
    EXPERIMENTOS 2
    ===================================================
    Mediciones lista:
    #{milisegundos_al_final}

    Mediciones mapa:
    #{milisegundos_al_inicio}
    ===================================================
    """
    |> Util.mostrar_mensaje()
  end
end

Mediciones.main()
