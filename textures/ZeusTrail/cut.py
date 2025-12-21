from PIL import Image, ImageFilter, ImageDraw
import os

image_list = os.listdir()

for i in image_list:
    if "ZeusTrail" in i:
        print(i)
        img = Image.open(i)
        x,y = img.size
        crop = (0,0,x/7,y)
        for j in range(6):
            crop = (x/7*j+200,0,x/7*(j+1)+200,y)
            crop2 = (x/7*(j+1)+200-30,0,x/7*(j+1)+200+30,y)
            cut_img = img.crop(crop).resize((226,150))
            cut_img.save("CutTrail\\ZeusTrail_"+str(j)+"_"+i[9:9+4]+".png")
            cut_img_join = img.crop(crop2).resize((60,150))
            cut_img_join.save("CutTrail\\ZeusTrailJoin"+str(j)+str(j+1)+i[9:9+4]+".png")

