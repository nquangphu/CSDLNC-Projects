﻿CREATE DATABASE shop_db;
go
USE shop_db;
go
--Bảng tài khoản
CREATE TABLE TAI_KHOAN
(
	TaiKhoan VARCHAR(20) PRIMARY KEY,
	MatKhau BINARY(16) NOT NULL,
	NgayLapTK DATETIME DEFAULT GETDATE() NOT NULL,
	--1: bình thường
	--0: khóa
	TrangThai BIT DEFAULT 1 NOT NULL,
	LoaiTK CHAR(2) NOT NULL
);
go
--Bảng nhân viên
CREATE TABLE NHAN_VIEN
(
	MaNV INT PRIMARY KEY IDENTITY(1, 1),
	TaiKhoan VARCHAR(20) NOT NULL,
	HoTenNV NVARCHAR(30) NOT NULL,
	DiaChiNV NVARCHAR(30) NOT NULL,
	NgaySinhNV DATE,
	EmailNV NVARCHAR(30) NOT NULL,
	SDT_NV VARCHAR(10) NOT NULL,
	LoaiNV CHAR(2) NOT NULL,
	LuongCung DECIMAL(15, 2) NOT NULL,
	LuongThuong DECIMAL(15, 2) DEFAULT 0 NOT NULL,
	FOREIGN KEY (TaiKhoan) REFERENCES TAI_KHOAN(TaiKhoan)
);
go
--Bảng khách hàng
CREATE TABLE KHACH_HANG
(
	MaKH INT PRIMARY KEY IDENTITY(1, 1),
	TaiKhoan VARCHAR(20) NOT NULL,
	HoTenKH NVARCHAR(30) NOT NULL,
	DiaChiKH NVARCHAR(30) NOT NULL,
	SDT_KH VARCHAR(10) NOT NULL,
	EmailKH VARCHAR(30) NOT NULL,
	NgaySinhKH DATE,
	DiemTichLuy INT DEFAULT 0 CONSTRAINT TAIKHOANKH_DiemTichLuy CHECK (DiemTichLuy >=0),
	SoTienDaDung DECIMAL(15,2) NOT NULL DEFAULT 0 CONSTRAINT TAIKHOANKH_SoTienDaDung CHECK (SoTienDaDung >=0),
	FOREIGN KEY (TaiKhoan) REFERENCES TAI_KHOAN(TaiKhoan)
);
go
--Bảng lương
CREATE TABLE LUONG
(
	MaNV INT NOT NULL,
	NgayCapNhatLuong DATETIME DEFAULT GETDATE() NOT NULL,
	LuongCung DECIMAL(15, 2) NOT NULL,
	LuongThuong DECIMAL(15, 2) DEFAULT 0 NOT NULL,
	PRIMARY KEY (MaNV, NgayCapNhatLuong),
	FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
go
--Bảng ca làm việc
CREATE TABLE CA_LAM_VIEC
(
	MaCa INT PRIMARY KEY,
	ThoiGianCa DATETIME NOT NULL DEFAULT GETDATE(),
	SoNhanVien INT NOT NULL DEFAULT 0,
);
go
--Bảng điểm danh
CREATE TABLE DIEM_DANH
(
	MaCa INT NOT NULL,
	MaNV INT NOT NULL,
	GioDiemDanh DATETIME DEFAULT NULL,
	PRIMARY KEY (MaCa, MaNV),
	FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV),
	FOREIGN KEY (MaCa) REFERENCES CA_LAM_VIEC(MaCa)
);
go
--Bảng nhà cung cấp
CREATE TABLE NHA_CUNG_CAP (
	MaNCC INT PRIMARY KEY IDENTITY(1, 1),
	TenNCC NVARCHAR(30) NOT NULL,
	DiaChiNCC NVARCHAR(30) NOT NULL,
	SDT_NCC VARCHAR(10) NOT NULL,
	EmailNCC VARCHAR(30) NOT NULL UNIQUE
);
go

--Bảng nhà cung cấp loại sản phẩm
CREATE TABLE NCC_LOAI_SP (
	MaNCC INT NOT NULL,
	LoaiSP NVARCHAR(30) NOT NULL,
	PRIMARY KEY (MaNCC, LoaiSP),
	FOREIGN KEY (MaNCC) REFERENCES NHA_CUNG_CAP(MaNCC)
);
go
--Bảng sản phẩm
CREATE TABLE SAN_PHAM (
	MaSP INT PRIMARY KEY IDENTITY(1, 1),
	TenSP NVARCHAR(30) NOT NULL,
	MoTaSP NVARCHAR(30) NOT NULL DEFAULT '',
	SoLuongTonKho INT DEFAULT 0 CONSTRAINT CHK_SoLuongTonKho CHECK (SoLuongTonKho >= 0),
	LoaiSP NVARCHAR(30) NOT NULL,
	DuongDanHinhAnh VARCHAR(30),
	GiaSP DECIMAL(15, 2) NOT NULL CONSTRAINT CHK_GiaSP CHECK (GiaSP >= 0),
);
GO

--Bảng lịch sử giá sản phẩm
CREATE TABLE LICH_SU_GIA (
	MaSP INT NOT NULL,
	NgayCapNhatGia DATETIME NOT NULL,
	GiaCapNhat DECIMAL(15, 2) NOT NULL CONSTRAINT CHK_GiaCapNhat CHECK (GiaCapNhat >= 0),
	PRIMARY KEY (MaSP, NgayCapNhatGia),
	FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);
go
--Bảng đơn hàng
CREATE TABLE DON_HANG (
    MaDH INT PRIMARY KEY IDENTITY(1,1),
	MaKH INT NOT NULL,
    NgayLapDH DATETIME NOT NULL DEFAULT GETDATE(),
    MaNV INT,
    TrangThaiDH NVARCHAR(20) NOT NULL DEFAULT N'Đang xử lý',
	TongGiaDH DECIMAL(15, 2) NOT NULL CONSTRAINT CHK_DH_TongGia CHECK (TongGiaDH >= 0),
	FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV),
	FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH)
);
go

--Bảng chi tiết đơn hàng
CREATE TABLE CHI_TIET_DON_HANG (
    MaDH INT NOT NULL,
    MaSP INT NOT NULL,
    DonGiaDH DECIMAL(15, 2) NOT NULL CONSTRAINT positive_ctdh_dongia CHECK (DonGiaDH >= 0),
    GiaGiamDH DECIMAL(15, 2) DEFAULT 0 CONSTRAINT positive_ctdh_giagiam CHECK (GiaGiamDH >= 0),
    SoLuongDH INT NOT NULL CONSTRAINT positive_ctdh_soluong CHECK (SoLuongDH > 0),
    PRIMARY KEY (MaDH,MaSP),
	FOREIGN KEY (MaDH) REFERENCES DON_HANG(MaDH),
	FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);

--Bảng chi tiết đơn đặt hàng
CREATE TABLE DON_DAT_HANG (
    MaDDH INT PRIMARY KEY IDENTITY(1,1),
    NgayLapDDH DATETIME NOT NULL DEFAULT GETDATE(),
	TrangThaiDDH NVARCHAR(20) NOT NULL DEFAULT N'Đang xử lý',
    MaNV INT NOT NULL,
	MaNCC INT NOT NULL,
	TongGiaDDH DECIMAL(15, 2) NOT NULL CONSTRAINT CHK_DDH_TongGia CHECK (TongGiaDDH >= 0),
	FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV),
	FOREIGN KEY (MaNCC) REFERENCES NHA_CUNG_CAP(MaNCC)
);


--Bảng chi tiết đơn đặt hàng
CREATE TABLE CHI_TIET_DON_DAT_HANG (
    MaDDH INT NOT NULL,
    MaSP INT NOT NULL,
    DonGiaDDH DECIMAL(15,2) NOT NULL CONSTRAINT positive_ctddh_dongia CHECK (DonGiaDDH >= 0),
    SoLuongDDH INT NOT NULL CONSTRAINT positive_ctddh_soluong CHECK (SoLuongDDH > 0),
    PRIMARY KEY (MaDDH,MaSP),
	FOREIGN KEY (MaDDH) REFERENCES DON_DAT_HANG(MaDDH),
	FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);
go
--Bảng đơn giao hàng
CREATE TABLE DON_GIAO_HANG (
    MaDGH INT PRIMARY KEY IDENTITY(1,1),
    NgayLapDGH DATETIME NOT NULL DEFAULT GETDATE(),
    MaDDH INT NOT NULL,
    MaNV INT NOT NULL,
	FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV),
	FOREIGN KEY (MaDDH) REFERENCES DON_DAT_HANG(MaDDH)
);
go
--Bảng chi tiết đơn giao hàng
CREATE TABLE CHI_TIET_DON_GIAO_HANG (
    MaDGH INT NOT NULL,
    MaSP INT NOT NULL,
    DonGiaDGH DECIMAL(15,2) NOT NULL CONSTRAINT positive_ctdgh_dongia CHECK (DonGiaDGH >= 0),
    SoLuongDGH INT DEFAULT 1 CONSTRAINT positive_ctdgh_soluong CHECK (SoLuongDGH > 0),
	PRIMARY KEY (MaDGH,MaSP),
	FOREIGN KEY (MaDGH) REFERENCES DON_GIAO_HANG(MaDGH),
	FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);
go
--Bảng thẻ ATM
CREATE TABLE THE_ATM (
	MaKH INT DEFAULT NULL,
	STK CHAR(10) PRIMARY KEY,
	TenChuKhoan NVARCHAR(30) NOT NULL,
	NganHang NVARCHAR(30) NOT NULL,
	FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH)
);
go
--Bảng thanh toán bằng ATM
CREATE TABLE THANH_TOAN_ATM (
	MaDH INT PRIMARY KEY,
	STK CHAR(10) NOT NULL,
	ThoiGianTT_ATM DATETIME NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (MaDH) REFERENCES DON_HANG(MaDH),
	FOREIGN KEY (STK) REFERENCES THE_ATM(STK)
);
go
--Bảng thanh toán bằng tiền mặt
CREATE TABLE THANH_TOAN_TIEN_MAT (
	MaDH INT PRIMARY KEY,
	ThoiGianTT_TM DATETIME NOT NULL DEFAULT GETDATE(),
	SoTienTraLai DECIMAL(15, 2) NOT NULL DEFAULT 0 CONSTRAINT CHK_SoTienTraLai CHECK (SoTienTraLai >= 0),
	FOREIGN KEY (MaDH) REFERENCES DON_HANG(MaDH)
);
go
--Bảng giỏ hàng
CREATE TABLE GIO_HANG (
	MaKH INT NOT NULL,
	MaSP INT NOT NULL,
	SoLuongGioHang INT NOT NULL DEFAULT 1 CHECK (SoLuongGioHang > 0),
	PRIMARY KEY (MaKH, MaSP),
	FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
	FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);