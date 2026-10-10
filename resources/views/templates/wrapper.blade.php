{{--
  VeruProject premium theme — v1.x wrapper template.
  This is the shell for ALL client-area pages (login, register, 2FA,
  dashboard, servers, console, files) mounted as a React SPA into #app.
  shortcut: re-apply after panel updates (php artisan view:clear). Kept
  contracts: @section meta/user-data, @yield('assets'), $asset->js('main.js'),
  $css['body'], Layouts.scripts partial.
--}}
<!DOCTYPE html>
<html>
    <head>
        <title>{{ config('app.name', 'Pterodactyl') }}</title>

        @section('meta')
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
            <meta name="csrf-token" content="{{ csrf_token() }}">
            <meta name="robots" content="noindex">

            <link rel="icon" type="image/png" href="https://cdn.veru.qzz.io/uDgbtf.png">
            <link rel="shortcut icon" href="https://cdn.veru.qzz.io/uDgbtf.png">
            <link rel="apple-touch-icon" href="https://cdn.veru.qzz.io/uDgbtf.png">
            <meta name="theme-color" content="#0a0e1a">
        @show

        @section('user-data')
            @if(!is_null(Auth::user()))
                <script>
                    window.PterodactylUser = {!! json_encode(Auth::user()->toVueObject()) !!};
                </script>
            @endif
            @if(!empty($siteConfiguration))
                <script>
                    window.SiteConfiguration = {!! json_encode($siteConfiguration) !!};
                </script>
            @endif
        @show

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="/themes/veruproject/css/app.css?v=1">

        @yield('assets')

        @include('layouts.scripts')
    </head>
    <body class="{{ $css['body'] ?? 'bg-neutral-50' }}">

        <div class="vq-loader">
            <div style="position:relative;display:flex;align-items:center;justify-content:center">
                <svg class="vq-loader__ring" viewBox="0 0 120 120" aria-hidden="true">
                    <circle class="vq-loader__track" id="vq-ring-track" cx="60" cy="60" r="54"></circle>
                    <circle class="vq-loader__bar" cx="60" cy="60" r="54"></circle>
                </svg>
                <img class="vq-loader__logo" alt="logo">
            </div>
            <span class="vq-loader__pct">0</span>
        </div>

        <div class="vq-bg" aria-hidden="true">
            <video autoplay muted loop playsinline src="https://cdn.veru.qzz.io/wWG4t8.mp4"></video>
        </div>

        @section('content')
            @yield('above-container')
            @yield('container')
            @yield('below-container')
        @show
        @section('scripts')
            {!! $asset->js('main.js') !!}
            <script src="/themes/veruproject/js/app.js?v=1"></script>
        @show

        <footer class="vq-credit">Template oleh VeruProject</footer>
    </body>
</html>