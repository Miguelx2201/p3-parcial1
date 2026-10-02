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
end
