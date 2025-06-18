from setuptools import setup, find_packages

setup(
    name="userbot",
    version="0.1.0",
    packages=find_packages(include=["userbot", "userbot.*"]),
    install_requires=[
        "telethon>=1.34.0",
        "PyYAML>=6.0",
        "openai>=0.27.0"
    ],
) 