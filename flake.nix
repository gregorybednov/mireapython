{
  description = "Python flake for MIREA desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      mireapython = pkgs.python3.withPackages (ps: with ps; [
                        ### Обработка данных ###
		numpy   # работа с многомерными массивами, линейной алгеброй
		pandas  # работа с табличными данными и/или временными рядами
		scipy   # научные вычисления (оптимизация, интеграция, статистика)

		seaborn matplotlib # визуализация данных (графики, диаграммы)

		        ### Мониторинг ###
		psutil     # управление и мониторинг системных ресурсов (CPU, память, процессы)
		py-cpuinfo # получение информации о процессоре

                       ### Работа с изображениями ###
		opencv4		# работа с изображениями OpenCV
		pillow          # альтернативная работа с изображениями

                       ### Утилиты ###
                tqdm             # прогресс-бары
		python-dateutil  # дата-время
                colorama         # цветной вывод
                debugpy          # дебаг
                loguru           # логи

                       ### Парадигмы программирования ###
                automat        # автоматное программирование через декораторы
                transitions  # ещё один инструмент для конечных автоматов
		cytoolz        # высокопроизводительные операций с коллекциями в парадигме ФП

                       ### Выход "во внешний мир": обвязки, API, пр. ###
               	requests       # сетевые запросы общего назначения
		beautifulsoup4 # парсинг сайтов
		simplejson     # обвязка на JSON
                pymodbus       # реализация Modbus
                gpiozero       # Raspberry Pi
                #pyserial      # реализация взаимодействия через COM-порт
                sqlalchemy     # ORM-инструмент для SQL
                psycopg2       # PostgreSQL
                opcua-widgets  # OPC UA
                pyrogram       # telegram-клиент на Python (как для ботов, так и для юзеров)
                cffi           # вызов функций из библиотек на C/C++

                       ### Нейросети ###
                torch            # нейросети, глубокое обучение
	    	torchvision      # дополнительные утилиты и модели для работы с изображениями в PyTorch
                albumentations   # аугментация изображение
		streamlit        # веб-приложения анализа данных
                ultralytics      # YOLO

                       ###  Django ###
		django                   # создание веб-приложений
		django-multiselectfield  # поддержка множественного выбора в моделях Django
		sorl-thumbnail           # генерация и управление миниатюрами изображений в Django
                django-filter            # фильтрация данных в запросах API
		django-types             # типизация для моделей и функций Django
		django-taggit            # управление тегами в приложениях Django
		django-context-decorator # упрощённое управление контекстами шаблонов
		django-annoying          # упрощение работы с Django
		django-simple-captcha    # добавляет простую капчу

	]);

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
			streamlit
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

in {
      packages.x86_64-linux.mireapython = mireapython;
      defaultPackage.x86_64-linux = mireapython;
      hydraJobs.default = self.packages.x86_64-linux.mireapython;
    };
}
