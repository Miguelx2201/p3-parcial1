defmodule Liquidacion do

  #Funciones para calcular el valor de un lote de prendas según el porcentaje de defectos
  def calcular_valor_lote(lote) when (lote.defectos <= 2) do
    valor_lote = lote.prendas * 3200 * 1.07
  end
  def calcular_valor_lote(lote) when (lote.defectos <= 5 && lote.defectos > 2) do
    valor_lote = lote.prendas * 3200 * 1
  end
  def calcular_valor_lote(lote) when (lote.defectos <= 10 && lote.defectos > 5) do
    valor_lote = lote.prendas * 3200 * 0.88
  end
  def calcular_valor_lote(lote) when (lote.defectos > 10) do
    valor_lote = lote.prendas * 3200 * 0.75
  end

  #Funciones para determinar si un confeccionista merece tener el bono de productividad diaria

  def merece_bono_diario?(lotes, codigo_confeccionista, dia) do
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
    Enum.filter(lotes, fn lote -> lote.codigo_confeccionista == codigo_confeccionista end)
  end

  def generar_lista_bonos_diarios_semana(lotes, codigo_confeccionista) do
    for dia <- 1..6 do
      if merece_bono_diario?(lotes, codigo_confeccionista, dia) do
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
end
