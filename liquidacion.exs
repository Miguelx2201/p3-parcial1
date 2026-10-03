defmodule Liquidacion do

  #Funciones para calcular el valor de un lote de prendas según el porcentaje de defectos
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

  #Funciones para determinar si un confeccionista merece tener el bono de productividad diaria

  def validar_merece_bono_diario?(lotes, codigo_confeccionista, dia) do
    total_prendas = calcular_prendas_diarias(lotes, codigo_confeccionista, dia)
    total_prendas >= 120
  end

  def calcular_prendas_diarias(lotes, codigo_confeccionista, dia) do
    lotes_del_dia = filtrar_lotes_diarios_confeccionista(lotes, codigo_confeccionista, dia)
    Enum.reduce(lotes_del_dia, 0, fn lote, acc -> acc + lote.prendas end)
  end

  def filtrar_lotes_diarios_confeccionista(lotes, codigo_confeccionista, dia) do
    lotes_confeccionista = filtrar_lotes_por_confeccionista(lotes, codigo_confeccionista)
    Enum.filter(lotes_confeccionista, fn lote -> lote.dia == dia end)
  end

  def filtrar_lotes_por_confeccionista(lotes, codigo_confeccionista) do
    Map.get(lotes, codigo_confeccionista)
  end

  def generar_lista_bonos_diarios_semana(lotes, codigo_confeccionista) do
    for dia <- 1..6 do
      if validar_merece_bono_diario?(lotes, codigo_confeccionista, dia) do
        18_000
      else
        0
      end
    end
  end

  def calcular_bono_total_semanal(lotes, codigo_confeccionista) do
    lista_bonos = generar_lista_bonos_diarios_semana(lotes, codigo_confeccionista)
    Enum.sum(lista_bonos)
  end

  def validar_confeccionista_alquila_maquina?(confeccionista) do
    confeccionista.alquiler
  end

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
  def calcular_descuento_total_semanal(lotes, confeccionista) do
    lista_descuentos = generar_lista_descuentos_alquiler_semanal(lotes, confeccionista)
    Enum.sum(lista_descuentos)
  end

  def calcular_total_semanal(lotes, confeccionista) do
    filtrar_lotes_por_confeccionista(lotes, confeccionista.codigo)
    |> Enum.map(&calcular_valor_lote/1)
    |> Enum.sum()
  end

  def calcular_neto_semanal(lotes, confeccionista) do
    total_semanal = calcular_total_semanal(lotes, confeccionista)
    bono_total = calcular_bono_total_semanal(lotes, confeccionista.codigo)
    descuento_total = calcular_descuento_total_semanal(lotes, confeccionista)
    total_semanal + bono_total - descuento_total
  end

  def ejecutar_ejemplo_maria do
    confeccionistas = %{
      "C1" => %{codigo: "C1", nombre: "María Elena Ríos", alquiler: true}
    }
    lotes = %{
      "C1" => [
        %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
        %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7},
        %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12}
      ]
    }
  calcular_neto_semanal(lotes, Map.get(confeccionistas, "C1"))
  |> IO.puts()
  end
end
Liquidacion.ejecutar_ejemplo_maria()
