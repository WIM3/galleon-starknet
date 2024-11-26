#[starknet::contract]
pub mod decimal{
    use galleon_starknet::contracts::utils::decimal_math::{decimal_math};

    #[derive(Copy,Drop,Serde)]
    pub struct decimal{
        d: u256
    }

    #[storage]
    struct Storage {}

    pub fn zero() -> decimal{
        return decimal{d:0};
    }

    pub fn one() -> decimal{
        return decimal{d: decimal_math::unit(@18_u256)};
    }

    pub fn toUint(x: decimal) -> u256{
        return x.d;
    }

    pub fn modD(x: decimal, y: decimal) -> decimal{
        return decimal{d: (x.d * decimal_math::unit(@18_u256)) % y.d};
    }

    pub fn cmp(x: decimal, y: decimal) -> i8{
        if(x.d > y.d){
            return 1;
        } else if(x.d < y.d){
            return -1;
        }
        return 0;
    }

    /// @dev add two decimals
    pub fn addD(x: decimal, y: decimal) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d + y.d;
        return t;

    }

    /// @dev subtract two decimals
    pub fn subD(x: decimal, y: decimal) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d - y.d;
        return t;
    }

    /// @dev multiple two decimals
    pub fn mulD(x: decimal, y: decimal) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d * y.d;
        return t;
    }

    /// @dev multiple a decimal by a uint256
    pub fn mulScalar(x: decimal, y: u256) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d * y;
        return t;
    }

    /// @dev divide two decimals
    pub fn divD(x: decimal, y: decimal) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d / y.d;
        return t;
    }

    /// @dev divide a decimal by a uint256
    pub fn divScalar(x: decimal, y: u256) -> decimal{
        let mut t: decimal = decimal{d:0};
        t.d = x.d / y;
        return t;
    }
}