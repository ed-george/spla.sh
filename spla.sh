#! /bin/bash

#================================================================================
# spla.sh
#
# A bash script to perform color operations
#
# In future, this will do a lot more!
#
# Usage is currently:
#
# ./spla.sh "#{color_code}"
#
# Returns a list of monochromatic colors
#
# E.g ./spla.sh "#120E23"
# Returns:
# #110E22
# #1F183C
# #2C2255
# ...and so on!
#
# WHAT'S NEW IN v1.00
# - All the things...
#
# Please check the LICENSE file before getting your grubby paws on this! 
#
# by Ed George <esm@hotmail.co.uk> 2014
#================================================================================

# Don't change this!
version="1.0"


#Globals
computedH=0
computedS=0
computedV=0

#http://bgrins.github.io/TinyColor/docs/tinycolor.html
monochromatic (){
 
    if [ -z "$1" ]
    then
        echo "ERR: No color param passed in monochromatic"
        exit -1
    fi

    COLOR=$1

    results=10

    r=$((0x${COLOR:1:2}))
    g=$((0x${COLOR:3:2}))
    b=$((0x${COLOR:5:2}))

    rgbToHsv $r $g $b

    modification=$(echo "scale=4; 1/$results" | bc)

    while [ $results -gt 0 ]
    do
        hsvToRgb $computedH $computedS $computedV
        computedV=$(echo "scale=4; ($computedV+$modification)" | bc)

        #Pretty sure this is a hack
        if [[ $computedV > 1 ]]; then

            return

        fi

        results=$[$results-1]
    done

}

floatToInt (){
    #ROUNDING ERRORS AHOY!
    var=$(printf %04f $1)
    echo ${var%.*}
}

intToHex  (){
    printf %02X $1 
}

rgbToString (){
    echo "#$(intToHex $1)$(intToHex $2)$(intToHex $3)"
}

#http://stackoverflow.com/questions/7896280/converting-from-hsv-hsb-in-java-to-rgb-without-using-java-awt-color-disallowe
rgbFloatToString (){
    r=$(floatToInt $(echo "scale=4; $1*255" | bc))
    g=$(floatToInt $(echo "scale=4; $2*255" | bc))
    b=$(floatToInt $(echo "scale=4; $3*255" | bc))
    rgbToString $r $g $b
}


#http://www.javascripter.net/faq/rgb2hsv.htm
rgbToHsv (){

    r=$(echo "scale=4; $1/255" | bc)
    g=$(echo "scale=4; $2/255" | bc)
    b=$(echo "scale=4; $3/255" | bc)

    #Reset to 0
    computedH=0
    computedS=0
    computedV=0

    color=($r $g $b)
    IFS=$'\n'
    #max
    maxRGB=$(echo "${color[*]}" | sort -nr | head -n1)
    #min
    minRGB=$(echo "${color[*]}" | sort -n | head -n1)
    
    if [[ $maxRGB == $minRGB ]]; then
        computedV=$minRGB
        return
    fi

     # var d = (r==minRGB) ? g-b : ((b==minRGB) ? r-g : b-r);

     d=0

     if [[ $r == $minRGB ]]; then

         d=$(echo "scale=4; $g-$b" | bc)    
     
     else
     
         if [[ $b == $minRGB ]]; then
             d=$(echo "scale=4; $r-$g" | bc)        
         else
            d=$(echo "scale=4; $b-$r" | bc)             
        fi    

     fi

     # var h = (r==minRGB) ? 3 : ((b==minRGB) ? 1 : 5);

     h=0

    if [[ $r == $minRGB ]]; then

         h=3    
     
     else
     
         if [[ $b == $minRGB ]]; then
             h=1    
         else
            h=5
        fi    

     fi

     # computedH = 60*(h - d/(maxRGB - minRGB));
     computedH=$(echo "scale=4; 60*($h-$d/($maxRGB-$minRGB))/360" | bc)
     computedS=$(echo "scale=4; ($maxRGB-$minRGB)/$maxRGB" | bc)
     computedV=$maxRGB
}

# Might be worth adding | awk '{printf "%f", $0}' to floats

#http://stackoverflow.com/questions/7896280/converting-from-hsv-hsb-in-java-to-rgb-without-using-java-awt-color-disallowe
hsvToRgb (){
    hue=$(printf %04f $1)
    sat=$(printf %04f $2)
    val=$(printf %04f $3)

    h=$(floatToInt $(echo "scale=4; $hue*6" | bc))

    f=$(echo "scale=4; ($hue*6)-$h" | bc)
    p=$(echo "scale=4; $val*(1-$sat)" | bc)
    q=$(echo "scale=4; $val*(1-$f*$sat)" | bc)
    t=$(echo "scale=4; $val*(1-(1-$f)*$sat)" | bc)

    case $h in
        0)
            rgbFloatToString $val $t $p
            ;;
        1)
            rgbFloatToString $q $val $p
            ;;
        2)
            rgbFloatToString $p $val $t
            ;;
        3)
            rgbFloatToString $p $q $val
            ;;
        4)
            rgbFloatToString $t $p $val
            ;;
        5)
            rgbFloatToString $val $p $q
            ;;
        6)
            rgbFloatToString $val $p $q
            ;;
        *)  echo "**Unexpected error in hsvToRgb**"
            exit -1
            ;;
    esac
}

#MAIN
 if [ -z "$1" ]
    then
        echo -e "\n\tUSAGE: ./spla \"#{color_code}\"\n"
        exit -1
 fi

monochromatic $1
