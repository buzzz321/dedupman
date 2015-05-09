defmodule DeDupman do
  def hello do
    IO.puts "/home/anders/Pictures/billudden/IMGP0849.jpg"
  end

  #----------------------------------------------------
  def get_files(path) do
    Path.wildcard(path <> "/**/*.jpg")
  end

  #----------------------------------------------------
  def put_in_map([], utdata) do
    utdata
  end

  def put_in_map([head | tail], utdata) do
    filnamn = Path.basename(head)

    if Dict.has_key?(utdata, filnamn) do
      #IO.puts "---" <> filnamn
      utdata = Dict.update!(utdata, filnamn, fn(val) -> [val, Path.dirname(head)] end)
    else
      #IO.puts "..." <> filnamn
      utdata = Dict.put(utdata, filnamn, Path.dirname(head))
    end

    put_in_map(tail, utdata)
  end

  #----------------------------------------------------
  def get_lens_info(filename) do
    res = System.cmd("exiv2" , ["-g", "Pentax.LensType",  filename])

    if (tuple_size(res) > 1 && String.length(elem(res,0)) > 59) do
      String.strip(elem(String.split_at(elem(res,0),60), 1))
    else
      ""
    end
  end

  #----------------------------------------------------
  def get_duplicates(data) do
    Enum.reduce data, [], fn({key,value},acc) ->
      case is_list(value) do
        true ->
          [{key,value}] ++ acc
        false ->
          acc
      end
    end
  end 

  #----------------------------------------------------
  def check_for_lens(tuple) do

    f1 = get_lens_info(hd(elem(tuple, 1)) <> "/" <> elem(tuple,0))
    f2 = get_lens_info(hd(tl(elem(tuple, 1))) <> "/" <> elem(tuple,0))

    if (f1 == "" && String.match?(f2, ~r"smc")) do
      #IO.puts "[#{f1}]"
      IO.puts hd(elem(tuple, 1)) <> "/" <> elem(tuple,0)
    end

    if (f2 == "" && String.match?(f1, ~r"smc")) do
      #IO.puts "[#{f2}]"
      IO.puts hd(tl(elem(tuple, 1))) <> "/" <> elem(tuple,0)
    end
  end

  #----------------------------------------------------
  def main(_args) do
    db = put_in_map(get_files("/home/anders/Pictures"), HashDict.new)
    #IO.inspect db

    dups = get_duplicates(db) 

    check_for_lens({"IMGP0792.jpg",["/home/anders/Pictures/2009/10/17", "/home/anders/Pictures/tekanna"]})
    #IO.inspect dups
    #IO.puts length dups

    Enum.map(dups, &check_for_lens/1)
    #IO.inspect get_lens_info("/home/anders/Pictures/Tysklandssemeter/IMGP1016.jpg")
    IO.puts "done"
  end
end
