{
  description = "Python flake for MIREA desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      ultralyticsThop = pkgs.python3.pkgs.buildPythonPackage rec {
        pname = "ultralytics-thop";
        version = "2.0.5";
        format = "pyproject";
        src = pkgs.fetchFromGitHub {
		      owner = "ultralytics";
		      repo = "thop";
		      rev = "v${version}";
		      sha256 = "sha256-1YvEFBw37C6Q/EJmC0do7dPv7BxwP9vbRhvw178NGAE=";
	      };  
	      propagatedBuildInputs = with pkgs.python312Packages; [ setuptools ];
	      buildInputs = with pkgs.python312Packages; [ torch numpy ];
      };
      ultralytics = pkgs.python3.pkgs.buildPythonPackage rec {
	      pname = "ultralytics";
       version = "8.2.82";
       format = "pyproject";
       src = pkgs.fetchPypi {
         inherit pname version;
         sha256 = "sha256-tb0Sb0Sy9iMrYl8kuKoBJZtSfXJo/LgfhOHIlyOFebY=";
      };
      nativeBuildInputs = [ pkgs.python312Packages.setuptools ];
      buildInputs = with pkgs.python312Packages; [
        numpy
		    scipy
		    torch
  	  	psutil
	    	pandas
    		seaborn
		    py-cpuinfo
		    torchvision
    		tqdm
		    requests
		    opencv4
	  ] ++ [ ultralyticsThop ];

  	# Patch to remove the strict version requirements that cause problems.
	  postPatch = ''
		cat pyproject.toml;
		substituteInPlace pyproject.toml \
			--replace "torchvision>=0.9.0" "torchvision" \
			--replace "opencv-python>=4.6.0" "opencv>=4.9.0"
	'';
	# Include opencv4 as opencv-python
	preBuild = "ln -s ${pkgs.python312Packages.opencv4} opencv-python";
};

mireapython = pkgs.python3.withPackages (ps: with ps; [
		numpy
		scipy
		matplotlib
		pillow
		colorama
		simplejson
		python-dateutil
		tqdm
		beautifulsoup4
		cytoolz
		pandas
		requests
		seaborn
		opencv4
		django
		django-multiselectfield
		sorl-thumbnail
		django-types
		django-taggit
		django-context-decorator
		django-annoying
		django-simple-captcha
		ultralytics
	]));

  in {
      packages.x86_64-linux.mireapython = mireapython;
      defaultPackage.x86_64-linux = mireapython;
    };
}
