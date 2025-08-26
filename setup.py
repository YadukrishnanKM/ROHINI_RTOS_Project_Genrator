from setuptools import setup, find_packages
import os

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# Library settings
LIB_DIR = os.path.join(ROOT_DIR, "..", "lib")
LIB_NAME = "libproj_gen_linux_x86_64.so"
LIB_PATH = os.path.join(LIB_DIR, LIB_NAME)

if not os.path.exists(LIB_PATH):
    print(f"⚠️ Shared library not found at: {LIB_PATH}")
    print("➡️ Build it with:")

setup(
    name="zig_proj_gen",
    version="0.2.4",
    description="Python ABI bindings for Zig Project Generator",
    author="Yadukrishnan K M",
    packages=find_packages(where="."),
    package_dir={"": "."},
    include_package_data=True,
    package_data={
        "": [f"../lib/{LIB_NAME}"],  # ensure .so file gets included in wheel
    },
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
    ],
    python_requires=">=3.8",
)
