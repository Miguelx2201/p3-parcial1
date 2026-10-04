defmodule Programa do
  def main do

    #Cargar datos crudos.
    confeccionistas_crudos = Datos.confeccionistas()
    lineas_crudos = Datos.lineas()
    lotes = Datos.lotes()

    #Transformar datos crudos a estructuras deseadas.
    confeccionistas = Util.confeccionistas_mapa(confeccionistas_crudos)
    lineas = Util.lineas_mapa(lineas_crudos)

    #Solicitar al usuario un lote adicional.
    lote_adicional = case Util.solicitar_lote_adicional() do
      {:ok, lote} ->
        Util.mostrar_mensaje("Lote agregado exitosamente.")
        lote
      {:error, motivo} ->
        Util.mostrar_mensaje("Error al agregar lote: #{motivo}")
        nil
      :omitido ->
        Util.mostrar_mensaje("Lote omitido.")
        nil
    end

    #Agregar el lote adicional a la lista de lotes si no es nil.
    lotes = if lote_adicional != nil, do: [lote_adicional | lotes], else: lotes

    lotes_separados = Validacion.separar_lotes(lotes)
    lotes_validos = lotes_separados.validos
    lotes_invalidos = lotes_separados.invalidos

    #Generar reportes y mostrarlos.
    Reportes.generar_reportes(lotes_validos, lotes_invalidos, confeccionistas, lineas)
    |> Util.mostrar_mensaje()

    #Solicitar comprobante confeccionista, validar si el proceso es correcto, en caso de serlo se muestra el comprobante.
    comprobante = Util.solicitar_y_mostrar_comprobante(lotes_validos, confeccionistas)
    case comprobante do
      {:ok, comprobante} ->
        Util.mostrar_mensaje("Comprobante generado exitosamente.")
        Util.mostrar_mensaje(comprobante)
      {:error, motivo} ->
        Util.mostrar_mensaje("Error al generar comprobante: #{motivo}")
    end
  end
end
