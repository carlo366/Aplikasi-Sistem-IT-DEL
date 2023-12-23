<?php

use App\Http\Controllers\AdminSuratController;
use App\Http\Controllers\authController;
use App\Http\Controllers\BookingRuanganController;
use App\Http\Controllers\productController;
use App\Http\Controllers\RequestizinBermalamController;
use App\Http\Controllers\RequestIzinKeluarController;
use App\Http\Controllers\RequestsuratController;
use App\Http\Controllers\RuanganController;
use App\Models\RequestizinBermalam;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::group(['middleware'=>['auth:sanctum']],function(){

    Route::get('/user',[RequestIzinKeluarController::class, 'user']);
    Route::post('/logout',[RequestIzinKeluarController::class, 'logout']);
    //
    Route::get('/izinkeluar',[RequestIzinKeluarController::class, 'index']);
    Route::get('/izinkeluarall',[RequestIzinKeluarController::class, 'indexadmin']);
    Route::post('/izinkeluar',[RequestIzinKeluarController::class, 'store']);
    Route::put('/izinkeluar/{id}',[RequestIzinKeluarController::class, 'update']);
    Route::get('/izinkeluar/{id}',[RequestIzinKeluarController::class, 'show']);
    Route::delete('/izinkeluar/{id}',[RequestIzinKeluarController::class, 'destroy']);
    Route::put('/{id}/approve', [RequestIzinKeluarController::class, 'approve']);

    // Endpoint untuk menolak permintaan izin keluar berdasarkan ID
    Route::put('/{id}/reject', [RequestIzinKeluarController::class, 'reject']);

    Route::get('/izinbermalam',[RequestizinBermalamController::class, 'index']);
    Route::get('/izinbermalamall',[RequestIzinBermalamController::class, 'indexadmin']);
    Route::post('/izinbermalam',[RequestizinBermalamController::class, 'store']);
    Route::put('/izinbermalam/{id}',[RequestizinBermalamController::class, 'update']);
    Route::get('/izinbermalam/{id}',[RequestizinBermalamController::class, 'show']);
    Route::delete('/izinbermalam/{id}',[RequestizinBermalamController::class, 'destroy']);
    Route::put('/{id}/approvee', [RequestIzinBermalamController::class, 'approve']);

    // Endpoint untuk menolak permintaan izin Bermalam berdasarkan ID
    //Izin_Surat
    Route::get('/surat',[RequestSuratController::class, 'index']);
    Route::post('/surat',[RequestSuratController::class, 'store']);
    Route::put('/surat/{id}',[RequestSuratController::class, 'update']);
    Route::get('/surat/{id}',[RequestSuratController::class, 'show']);
    Route::delete('/surat/{id}',[RequestSuratController::class, 'destroy']);
    Route::get('/admin/surat',[AdminSuratController::class, 'index']);
    Route::get('/admin/surats',[AdminSuratController::class, 'indexsemua']);
    Route::put('/admin/surat/approve/{id}', [AdminSuratController::class, 'approve']);
    Route::put('/admin/surat/rejected/{id}', [AdminSuratController::class, 'rejected']);


    //Booking_Ruangan
    Route::get('/booking-ruangan', [BookingRuanganController::class, 'index']);
     Route::post('/booking-ruangan', [BookingRuanganController::class, 'bookRoom']);
     Route::post('/cek-ruangan', [BookingRuanganController::class, 'RoomAvailable']);
     Route::delete('/booking-ruangan/{id}', [BookingRuanganController::class, 'destroy']);
     Route::get('/admin/surat',[AdminSuratController::class, 'index']);
     Route::get('/admin/surats',[AdminSuratController::class, 'indexsemua']);
     Route::put('/admin/surat/approve/{id}', [AdminSuratController::class, 'approve']);
     Route::put('/admin/surat/rejected/{id}', [AdminSuratController::class, 'rejected']);


     Route::get('/ruangan', [RuanganController::class, 'index']);

});

Route::post('registerUser',[authController::class,'registerUser']);
Route::post('loginUser',[authController::class,'loginUser']);
