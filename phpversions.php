<?php

const CACHE_FILE = __DIR__ . '/ls-remote.txt';

function main($argc, array $argv)
{
    if (file_exists(CACHE_FILE)) {
        $last_modified = filemtime(CACHE_FILE);
        if ($last_modified > strtotime('-2 weeks')) {
            $bytes = readfile(CACHE_FILE);
            if ($bytes !== false) {
                return 0;
            }
            error_log('cache file is broken. remove ' . CACHE_FILE);
            return 1;
        }
    }

    ob_start();

    $host = getenv('PHP_NET_HOST');
    if (!$host) {
        $host = 'https://www.php.net';
    }

    $phpall = download($host . '/releases/index.php?serialize');
    $phpall = unserialize($phpall);
    foreach ($phpall as $major => $info) {
        $phpver = download("$host/releases/index.php?serialize&version=$major&max=1000");
        $phpver = unserialize($phpver);
        $phpver = array_keys($phpver);

        say("\n## $major");
        usort($phpver, 'version_compare');

        $miner = 0;
        $i = 0;
        $basever = "$major.$miner";
        say("### $basever");
        foreach ($phpver as $ver) {
            if (0 !== strncmp($ver, $basever, strlen($basever))) {
                ++$miner;
                $basever = "$major.$miner";
                say("\n\n### $basever");
                $i = 0;
            }
            echo "$ver\t";
            if (++$i > 9) {
                echo PHP_EOL;
                $i = 0;
            }
        }

        echo PHP_EOL;
    }

    $result = ob_get_clean();
    file_put_contents(CACHE_FILE, $result);
    echo $result;

    return 0;
}

function say($str)
{
    echo $str, PHP_EOL;
}

interface CurlException
{
}

class ConnectException extends RuntimeException implements CurlException
{
}

class HttpException extends RuntimeException implements CurlException
{
}

function download($url) {
    static $ch;
    if (!$ch) $ch = curl_init();

    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_ENCODING => '',
    ]);

    $response = curl_exec($ch);

    $errno = curl_errno($ch);
    if ($errno !== CURLE_OK) {
        throw new ConnectException(curl_error($ch), $errno);
    }

    $info = curl_getinfo($ch);
    if ($info['http_code'] >= 400) {
        throw new HttpException($info['http_code'], $response);
    }

    return $response;
}

die(main($argc, $argv));
