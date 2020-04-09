#!/usr/bin/env python
# -*- coding: utf-8 -*
import requests 
from bs4 import BeautifulSoup,Tag 
from PIL import Image,ImageDraw
from pathlib import Path

"""
developed on Sublime Text
MacOSX and Xcode
by Dennis Mostajo
"""
start_uri = "http://www.proveyourworth.net/level3/start"
activate_uri = "http://www.proveyourworth.net/level3/activate?statefulhash"
payload = "http://www.proveyourworth.net/level3/payload"
file_path = Path("./")

session = requests.Session()

def start_session(start_uri: str) -> None:
    session.get(start_uri)
    print(session)
    print(f'Hash: {session.cookies.get("PHPSESSID")}')


def get_hash(start_uri: str) -> str:
    request = session.get(start_uri)
    soup = BeautifulSoup(request.text, 'html.parser')
    return soup.find("input",{"name":"statefulhash"})['value']

def activate(activate_uri,get_hash: str) -> None:
    get_hash = get_hash(start_uri)
    session.get(activate_uri+f'={get_hash}')
    print(f"Hash: {get_hash}")
  
def get_image_to_sign(uri_image: str) -> bytes:
    request = session.get(uri_image,stream=True)
    image = request.raw
    return image

def sing_image(image: bytes) -> None:
    image = Image.open(image)
    draw = ImageDraw.Draw(image)
    draw.text((20,70), f"Dennis Mostajo Maldonado, \n hash:{get_hash(start_uri)} \n iOS and Android Developer", fill=(1024,1024,0))
    image.save("image.jpg","JPEG")
    
    
def post_back_to(payload: str) -> None:
    payload = session.get(payload)
    post_uri = f"{payload.headers['X-Post-Back-To']}"
    print(post_uri)
    file = {
        "code":open(file_path / "code.py","rb"),
        "resume":open(file_path / "resume.pdf","rb"),
        "image":open(file_path / "image.jpg","rb")
    }
    data = {
        "email":"mostygt@gmail.com",
        "name":"Dennis Mostajo Maldonado",
        "aboutme": "I'm an iOS & Android developer with extensive experience in building high quality mobile Apps"
        #"code":"https://github.com/DennisMostajo",
        #"resume":"https://www.linkedin.com/in/dennis-mostajo-maldonado-536b9a68",
        #"image":"https://github.com/DennisMostajo/iOSCocos2DTest/blob/master/d1.png"
    }
    request = session.post(post_uri, data=data, files=file)
    print(request.status_code)
    print(request.text)

if __name__ == '__main__':
    print("-"*8 + "🚬🗿 start PHPSESSID" + "-"*8)
    start_session(start_uri)
    print("-"*8 + "🤘💀 hacking PHPSESSID" + "-"*8)
    print("-"*8 +"🇧🇴♋ activate PHPSESSID" + "-"*8)
    activate(activate_uri,get_hash)
    print("-"*8 +"🖖👽 activated payload" + "-"*8)
    sing_image(get_image_to_sign(payload))
    print("-"*8 + "status code:")
    post_back_to(payload)