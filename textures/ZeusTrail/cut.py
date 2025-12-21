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
            crop2 = (x/7*(j)+200-30,0,x/7*(j+1)+200+30,y)
            cut_img = img.crop(crop2)
            # data=cut_img.load()
            # for k in range(0,30):
            #     for l in range(cut_img.size[1]):
            #         r,g,b,a = data[k,l]
            #         # print(r,g,b,a)
            #         data[k,l] = (r,g,b,int(a*k/30))
            #         r,g,b,a = data[cut_img.size[0]-k-1,l]
            #         data[cut_img.size[0]-k-1,l] = (r,g,b,int(a*k/30))
            cut_img = cut_img.resize((296,150))
            cut_img.save("CutTrail\\ZeusTrail_"+str(j)+"_"+i[9:9+4]+".png")
            # cut_img_join = img.crop(crop2).resize((60,150))
            # cut_img_join.save("CutTrail\\ZeusTrailJoin"+str(j)+str(j+1)+i[9:9+4]+".png")

