#!/bin/sh

# 초기화가 필요할 경우만 실행
if [ ! -f /.initialized ]; then
    echo "Running initialization scripts..."

    # 데이터베이스와 테이블이 준비된 상태인지 확인
    echo "Waiting for MySQL to be ready..."
    /wait-for-it.sh mysql:3306 --timeout=60 --strict -- echo "MySQL is up."

    # 마이그레이션 실행
    echo "Running migrations..."
    php /var/www/html/E_Global_Zone/artisan migrate --force

    # Passport public key 생성
    echo "Generating passport keys..."
    php /var/www/html/E_Global_Zone/artisan passport:install --force
    
    # 초기화 완료 마크 파일 생성
    touch /.initialized
else
    echo "Initialization already completed."
fi

# PHP-FPM 실행
echo "Starting PHP-FPM..."
exec php-fpm