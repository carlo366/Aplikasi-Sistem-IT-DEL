<?php

namespace App\Http\Controllers;

use App\Models\Requestsurat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class RequestsuratController extends Controller
{
    public function index()
    {
        // Mendapatkan pengguna yang sedang login
        $user = Auth::user();

        // Mengambil data RequestSurat sesuai dengan user yang login
        $izinKeluarData = RequestSurat::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response([
            'RequestSurat' => $izinKeluarData
        ], 200);
    }
    public function show($id)
    {
        return response([
            'RequestSurat' => RequestSurat::where('id', $id)->get()
        ], 200);
    }


    public function store(Request $request)
    {
        $rules = [
            'reason' => 'required|string',
            'pengajuan' => 'required|date', // Tambahkan validasi untuk kolom pengajuan
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $user = RequestSurat::create([
            'reason' => $request->input('reason'),
            'user_id' => auth()->user()->id,
            'pengajuan' => $request->input('pengajuan'), // Tambahkan pengaturan untuk kolom pengajuan
        ]);

        return response([
            'message' => 'Request Izin Keluar dibuat',
            'RequestSurat' => $user,
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $requestSurat = RequestSurat::find($id);

        if (!$requestSurat) {
            return response([
                'message' => 'Request Izin Keluar Tidak Ditemukan',
            ], 403);
        }

        if ($requestSurat->user_id != auth()->user()->id) {
            return response([
                'message' => 'Akun Anda Tidak mengakses Ini',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'reason' => 'required|string',
            'pengajuan' => 'required|date', // Tambahkan validasi untuk kolom pengajuan
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $requestSurat->update([
            'reason' => $request->input('reason'),
            'pengajuan' => $request->input('pengajuan'), // Tambahkan pengaturan untuk kolom pengajuan
        ]);

        return response([
            'message' => 'Request Izin Keluar Telah Diupdate',
            'RequestSurat' => $requestSurat
        ], 200);
    }


   public function destroy($id){
    $RequestSurat= RequestSurat::find($id);
    if(!$RequestSurat){
     return response([
         'message' => 'Request Izin Keluar Tidak Ditemukan',
     ], 403);
    }
    if($RequestSurat->user_id !=auth()->user()->id){
     return response([
         'message' => 'Akun Anda Tidak mengakses Ini',
     ], 403);
    }
    $RequestSurat->delete();
    return response([
        'message' => 'Request Izin Keluar Telah Dihapus',
        'RequestSurat'=>$RequestSurat
    ], 200);
   }
}
