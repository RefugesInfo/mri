file=$1
out=$2

options=""


#gdal_fillnodata.py $file

#option, réduire taille : -tr 90 90 
gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs "EPSG:3857" -r bilinear -tr 180 180 $file warp.tif -overwrite
#gdal_fillnodata.py warp.tif

gdaldem hillshade -z 0.7 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp.tif hs.tif
gdaldem color-relief warp.tif relief_color_text_file.txt color-relief.tif -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG -co PREDICTOR=2 #-alpha

gdal_calc.py -A hs.tif --outfile=gamma_hillshade.tif --calc="uint8(((A / 255.)**(1/0.5)) * 255)" --overwrite
gdal_calc.py -A  gamma_hillshade.tif -B color-relief.tif --allBands=B --calc="uint8( (  2 * (A/255.)*(B/255.)*(A<128) +  ( 1 - 2 * (1-(A/255.))*(1-(B/255.)) ) * (A>=128)  ) * 255 )" --outfile=colored_hillshade.tif --co BIGTIFF=YES --co TILED=YES --co COMPRESS=JPEG --overwrite

gdal_translate colored_hillshade.tif $out
