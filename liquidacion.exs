defmodule Liquidacion do
  @moduledoc """
  Módulo para gestionar los cálculos relacionados con la liquidación de confeccionistas. Incluye funciones para
  calcular el valor de lotes de prendas, la validación de bonos y descuentos, y el cálculo del neto semanal de
  cada confeccionista.
  """

  @doc """
  Calcula el valor de un lote de prendas según el porcentaje de defectos.
  Si el porcentaje de defectos es menor o igual a 2, se le aplica un incremento del 7% al valor base de cada prenda.
  Si el porcentaje de defectos es menor o igual a 5, no se le aplica ningún incremento.
  Si el porcentaje de defectos es menor o igual a 10, se le aplica un descuento del 12% al valor base de cada prenda.
  Si el porcentaje de defectos es mayor a 10, se le aplica un descuento del 25% al valor base de cada prenda.
  """
  def calcular_valor_lote(lote) when (lote.defectos <= 2) do
    lote.prendas * 3200 * 1.07
  end
  def calcular_valor_lote(lote) when (lote.defectos <= 5) do
    lote.prendas * 3200 * 1
  end
  def calcular_valor_lote(lote) when (lote.defectos <= 10) do
    lote.prendas * 3200 * 0.88
  end
  def calcular_valor_lote(lote) when (lote.defectos > 10) do
    lote.prendas * 3200 * 0.75
  end
  @doc """
  Valida si un confeccionista merece un bono diario basado en la cantidad de prendas que ha confeccionado ese día.
  Recibe un mapa de lotes, un código de confeccionista y un día.
  Devuelve true si el confeccionista ha confeccionado 120 o más prendas ese día, de lo contrario false.
  """
  def validar_merece_bono_diario?(lotes, codigo_confeccionista, dia) do
    total_prendas = calcular_prendas_diarias(lotes, codigo_confeccionista, dia)
    total_prendas >= 120
  end

  @doc """
  Calcula la cantidad total de prendas confeccionadas por un confeccionista en un día específico.
  Recibe un mapa de lotes, un código de confeccionista y un día.
  Devuelve la suma total de prendas confeccionadas ese día por ese confeccionista.
  """
  def calcular_prendas_diarias(lotes, codigo_confeccionista, dia) do
    lotes_del_dia = filtrar_lotes_diarios_confeccionista(lotes, codigo_confeccionista, dia)
    Enum.reduce(lotes_del_dia, 0, fn lote, acc -> acc + lote.prendas end)
  end

  @doc """
  Filtra los lotes de un confeccionista que se han producido en un día específico.
  Recibe un mapa de lotes, un código de confeccionista y un día.
  Devuelve una lista de lotes del confeccionista que se han producido ese día.
  """
  def filtrar_lotes_diarios_confeccionista(lotes, codigo_confeccionista, dia) do
    lotes_confeccionista = filtrar_lotes_por_confeccionista(lotes, codigo_confeccionista)
    Enum.filter(lotes_confeccionista, fn lote -> lote.dia == dia end)
  end

  @doc """
  Filtra los lotes de un confeccionista.
  Recibe un mapa de lotes y un código de confeccionista.
  Devuelve una lista de lotes del confeccionista.
  """
  def filtrar_lotes_por_confeccionista(lotes, codigo_confeccionista) do
    Enum.filter(lotes, fn lote -> lote.codigo_confeccionista == codigo_confeccionista end)
  end

  @doc """
  Genera una lista de bonos diarios por semana para un confeccionista basada en su rendimiento.
  Recibe un mapa de lotes y un código de confeccionista.
  Devuelve una lista de bonos diarios por semana (6 días de trabajo).
  """
  def generar_lista_bonos_diarios_semana(lotes, codigo_confeccionista) do
    for dia <- 1..6 do
      if validar_merece_bono_diario?(lotes, codigo_confeccionista, dia) do
        18_000
      else
        0
      end
    end
  end

  @doc """
  Calcula el bono total semanal para un confeccionista basado en su rendimiento.
  Recibe un mapa de lotes y un código de confeccionista.
  Devuelve el bono total semanal.
  """
  def calcular_bono_total_semanal(lotes, codigo_confeccionista) do
    lista_bonos = generar_lista_bonos_diarios_semana(lotes, codigo_confeccionista)
    Enum.sum(lista_bonos)
  end

  @doc """
  Valida si un confeccionista alquila una máquina.
  Recibe un confeccionista.
  Devuelve true si el confeccionista alquila una máquina, de lo contrario false.
  """
  def validar_confeccionista_alquila_maquina?(confeccionista) do
    confeccionista.alquiler
  end

  @doc """
  Genera una lista de descuentos por alquiler semanal para un confeccionista basada en su actividad diaria.
  Recibe un mapa de lotes y un confeccionista.
  Devuelve una lista de descuentos por alquiler diarios por semana (6 días de trabajo).
  """
  def generar_lista_descuentos_alquiler_semanal(lotes, confeccionista) do
    if validar_confeccionista_alquila_maquina?(confeccionista) do
      for dia <- 1..6 do
        lotes_del_dia = filtrar_lotes_diarios_confeccionista(lotes, confeccionista.codigo, dia)
        if Enum.any?(lotes_del_dia) do
          15_000
        else
          0
        end
      end
    else
      [0,0,0,0,0,0]
    end
  end

  @doc """
  Calcula el descuento total semanal por alquiler para un confeccionista basado en su actividad diaria.
  Recibe un mapa de lotes y un confeccionista.
  Devuelve el descuento total semanal por alquiler.
  """
  def calcular_descuento_total_semanal(lotes, confeccionista) do
    lista_descuentos = generar_lista_descuentos_alquiler_semanal(lotes, confeccionista)
    Enum.sum(lista_descuentos)
  end

  @doc """
  Calcula el total semanal de un confeccionista según el valor de lotes.
  Recibe un mapa de lotes y un confeccionista.
  Devuelve el total semanal.
  """
  def calcular_total_semanal(lotes, confeccionista) do
    filtrar_lotes_por_confeccionista(lotes, confeccionista.codigo)
    |> Enum.map(&calcular_valor_lote/1)
    |> Enum.sum()
  end

  @doc """
  Calcula el neto semanal de un confeccionista teniendo en cuenta el valor de los lotes, los bonos y los descuentos.
  Recibe un mapa de lotes y un confeccionista.
  Devuelve el neto semanal.
  """
  def calcular_neto_semanal(lotes, confeccionista) do
    total_semanal = calcular_total_semanal(lotes, confeccionista)
    bono_total = calcular_bono_total_semanal(lotes, confeccionista.codigo)
    descuento_total = calcular_descuento_total_semanal(lotes, confeccionista)
    total_semanal + bono_total - descuento_total
  end

  def ejecutar_ejemplo_maria do
    confeccionista = %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true}

    # Lotes en lista plana de mapas
    lotes = [
      %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7.0},
      %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12.0}
    ]

    neto = calcular_neto_semanal(lotes, confeccionista)
    IO.puts("Pago neto de María Elena: $#{neto}")
  end

  @doc """
Genera la lista consolidada de liquidaciones para todos los confeccionistas.
Devuelve una lista de mapas con las métricas necesarias para reportes y rankings:
:codigo, :nombre, :bruto, :neto y :prendas.
"""
def generar_liquidaciones(lotes_validos, mapa_confeccionistas) do
  mapa_confeccionistas
  |> Map.values()
  |> Enum.map(fn confeccionista ->
    lotes_conf = filtrar_lotes_por_confeccionista(lotes_validos, confeccionista.codigo)

    %{
      codigo: confeccionista.codigo,
      nombre: confeccionista.nombre,
      bruto: calcular_total_semanal(lotes_validos, confeccionista),
      neto: calcular_neto_semanal(lotes_validos, confeccionista),
      prendas: Enum.sum_by(lotes_conf, fn lote -> lote.prendas end)
    }
    end)
  end
end
